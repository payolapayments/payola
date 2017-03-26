require 'spec_helper'

module Payola
  describe SubscriptionsController do
    routes { Payola::Engine.routes }

    before do
      @plan = create(:subscription_plan)
      Payola.register_subscribable(@plan.class)
    end

    describe '#create' do

      let(:tax_percent) { 20 }

      it "should pass args to CreateSubscription" do
        subscription = double
        expect(subscription).to receive(:save).and_return(true)
        expect(subscription).to receive(:guid).at_least(1).times.and_return(1)
        expect(subscription).to receive(:error).and_return(nil)
        errors = double
        expect(errors).to receive(:full_messages).and_return([])
        expect(subscription).to receive(:errors).and_return(errors)
        expect(subscription).to receive(:state).and_return('pending')

        expect(CreateSubscription).to receive(:call).with(
          permitted_params(
            'plan_class' => 'subscription_plan',
            'plan_id' => @plan.id.to_s,
            'tax_percent' => tax_percent.to_s,
            'controller' => 'payola/subscriptions',
            'action' => 'create',
            'plan' => @plan,
            'coupon' => nil,
            'quantity' => 1,
            'affiliate' => nil
          )
        ).and_return(subscription)

        post :create, params: { plan_class: @plan.plan_class, plan_id: @plan.id, tax_percent: tax_percent }

        expect(response.status).to eq 200
        parsed_body = JSON.load(response.body)
        expect(parsed_body['guid']).to eq 1
      end

      describe "with an error" do
        it "should return an error in json" do
          subscription = double
          expect(subscription).to receive(:save).and_return(false)
          error = double
          expect(error).to receive(:full_messages).and_return(['done did broke'])
          expect(subscription).to receive(:errors).and_return(error)
          expect(subscription).to receive(:state).and_return('errored')
          expect(subscription).to receive(:error).and_return('')
          expect(subscription).to receive(:guid).and_return('blah')


          expect(CreateSubscription).to receive(:call).and_return(subscription)
          expect(Payola).to_not receive(:queue!)

          post :create, params: { plan_class: @plan.plan_class, plan_id: @plan.id }

          expect(response.status).to eq 400
          parsed_body = JSON.load(response.body)
          expect(parsed_body['error']).to eq 'done did broke'
        end
      end
    end

    describe '#status' do
      it "should return 404 with no response body if it can't find the subscription" do
        get :status, params: { guid: 'doesnotexist' }
        expect(response.status).to eq 404
        expect(response.body).to be_blank
      end
      it "should return json with properties" do
        subscription = create(:subscription)
        get :status, params: { guid: subscription.guid }

        expect(response.status).to eq 200

        parsed_body = JSON.load(response.body)

        expect(parsed_body['guid']).to eq subscription.guid
        expect(parsed_body['status']).to eq subscription.state
        expect(parsed_body['error']).to be_nil
      end
    end

    describe '#show' do
      it "should redirect to the product's redirect path" do
        plan = create(:subscription_plan)
        subscription = create(:subscription, :plan => plan)
        get :show, params: { guid: subscription.guid }

        expect(response).to redirect_to '/'
      end
    end

    describe '#destroy' do
      before :each do
        @subscription = create(:subscription, state: :active, stripe_customer_id: Stripe::Customer.create.id)
      end
      it "call Payola::CancelSubscription and redirect" do
        expect(Payola::CancelSubscription).to receive(:call)
        delete :destroy, params: { guid: @subscription.guid }
        # TODO : Figure out why this needs to be a hardcoded path.
        # Why doesn't subscription_path(@subscription) work?
        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
      end

      it "should redirect with an error if it can't cancel the subscription" do
        expect(Payola::CancelSubscription).to_not receive(:call)
        expect_any_instance_of(::ApplicationController).to receive(:payola_can_modify_subscription?).and_return(false)

        delete :destroy, params: { guid: @subscription.guid }
        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'You cannot modify this subscription.'
      end

      it "coerce the at_period_end param to a boolean, and pass it through to Payola::CancelSubscription" do
        expect(Payola::CancelSubscription).to receive(:call).with(instance_of(Payola::Subscription), at_period_end: true)
        delete :destroy, params: { guid: @subscription.guid, at_period_end: 'true' }
      end
    end

    describe '#change_plan' do
      before :each do
        @subscription = create(:subscription, state: :active, stripe_customer_id: Stripe::Customer.create.id)
        @plan = create(:subscription_plan)
        @quantity = 1
        @coupon = nil
        @trial_end = "now"
      end

      it "should call Payola::ChangeSubscriptionPlan and redirect" do
        expect(Payola::ChangeSubscriptionPlan).to receive(:call).with(@subscription, @plan, @quantity, @coupon, @trial_end)

        post :change_plan, params: { guid: @subscription.guid, plan_class: @plan.plan_class, plan_id: @plan.id, trial_end: @trial_end }

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:notice]).to eq 'Subscription plan updated'
      end

      it "should show error if Payola::ChangeSubscriptionPlan fails" do
        StripeMock.prepare_error(Stripe::StripeError.new('There was a problem changing the subscription'))

        post :change_plan, params: { guid: @subscription.guid, plan_class: @plan.plan_class, plan_id: @plan.id }

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'There was a problem changing the subscription'
      end

      it "should redirect with an error if it can't update the subscription" do
        expect(Payola::ChangeSubscriptionPlan).to_not receive(:call)
        expect_any_instance_of(::ApplicationController).to receive(:payola_can_modify_subscription?).and_return(false)

        post :change_plan, params: { guid: @subscription.guid, plan_class: @plan.plan_class, plan_id: @plan.id }
        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'You cannot modify this subscription.'
      end
    end

    describe '#change_quantity' do
      before :each do
        @subscription = create(:subscription, state: :active, stripe_customer_id: Stripe::Customer.create.id)
        @plan = create(:subscription_plan)
      end

      it "should call Payola::ChangeSubscriptionQuantity and redirect" do
        expect(Payola::ChangeSubscriptionQuantity).to receive(:call).with(@subscription, 5)

        post :change_quantity, params: { guid: @subscription.guid, quantity: 5 }

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:notice]).to eq 'Subscription quantity updated'
      end

      it "should show error if Payola::ChangeSubscriptionQuantity fails" do
        StripeMock.prepare_error(Stripe::StripeError.new('There was a problem changing the subscription quantity'))

        post :change_quantity, params: { guid: @subscription.guid, quantity: 5 }

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'There was a problem changing the subscription quantity'
      end

      it "should redirect with an error if it can't update the subscription" do
        expect(Payola::ChangeSubscriptionQuantity).to_not receive(:call)
        expect_any_instance_of(::ApplicationController).to receive(:payola_can_modify_subscription?).and_return(false)

        post :change_quantity, params: { guid: @subscription.guid, quantity: 5 }
        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'You cannot modify this subscription.'
      end
    end

    describe "#update_card" do
      before :each do
        @subscription = create(:subscription, state: :active, stripe_customer_id: Stripe::Customer.create.id)
        @plan = create(:subscription_plan)
      end

      it "should call UpdateCard and redirect" do
        expect(Payola::UpdateCard).to receive(:call).with(@subscription, 'tok_1234')

        post :update_card, params: { guid: @subscription.guid, stripeToken: 'tok_1234' }

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:notice]).to eq 'Card updated'
      end

      it "should show error if Payola::UpdateCare fails" do
        StripeMock.prepare_error(Stripe::StripeError.new('There was a problem updating the card'))

        post :update_card, params: { guid: @subscription.guid, stripeToken: 'tok_1234' }

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'There was a problem updating the card'
      end

      it "should redirect with an error" do
        expect(Payola::UpdateCard).to receive(:call).never
        expect_any_instance_of(::ApplicationController).to receive(:payola_can_modify_subscription?).and_return(false)

        post :update_card, params: { guid: @subscription.guid, stripeToken: 'tok_1234' }

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'You cannot modify this subscription.'
      end

      it "should throw error if controller doesn't define payola_can_modify_subscription?" do
        expect(Payola::UpdateCard).to receive(:call).never
        controller.instance_eval('undef :payola_can_modify_subscription?')

        expect {
          post :update_card, params: { guid: @subscription.guid, stripeToken: 'tok_1234' }
        }.to raise_error(NotImplementedError)
      end
    end

  end
end
