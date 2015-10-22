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
        subscription.should_receive(:save).and_return(true)
        subscription.should_receive(:guid).at_least(1).times.and_return(1)
        subscription.should_receive(:error).and_return(nil)
        errors = double
        errors.should_receive(:full_messages).and_return([])
        subscription.should_receive(:errors).and_return(errors)
        subscription.should_receive(:state).and_return('pending')

        CreateSubscription.should_receive(:call).with(
          'plan_class' => 'subscription_plan',
          'plan_id' => @plan.id.to_s,
          'tax_percent' => tax_percent.to_s,
          'controller' => 'payola/subscriptions',
          'action' => 'create',
          'plan' => @plan,
          'coupon' => nil,
          'quantity' => 1,
          'affiliate' => nil
        ).and_return(subscription)

        post :create, plan_class: @plan.plan_class, plan_id: @plan.id, tax_percent: tax_percent

        expect(response.status).to eq 200
        parsed_body = JSON.load(response.body)
        expect(parsed_body['guid']).to eq 1
      end

      describe "with an error" do
        it "should return an error in json" do
          subscription = double
          subscription.should_receive(:save).and_return(false)
          error = double
          error.should_receive(:full_messages).and_return(['done did broke'])
          subscription.should_receive(:errors).and_return(error)
          subscription.should_receive(:state).and_return('errored')
          subscription.should_receive(:error).and_return('')
          subscription.should_receive(:guid).and_return('blah')


          CreateSubscription.should_receive(:call).and_return(subscription)
          Payola.should_not_receive(:queue!)

          post :create, plan_class: @plan.plan_class, plan_id: @plan.id

          expect(response.status).to eq 400
          parsed_body = JSON.load(response.body)
          expect(parsed_body['error']).to eq 'done did broke'
        end
      end
    end

    describe '#status' do
      it "should return 404 if it can't find the subscription" do
        get :status, guid: 'doesnotexist'
        expect(response.status).to eq 404
      end
      it "should return json with properties" do
        subscription = create(:subscription)
        get :status, guid: subscription.guid

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
        get :show, guid: subscription.guid

        expect(response).to redirect_to '/'
      end
    end

    describe '#destroy' do
      before :each do
        @subscription = create(:subscription, :state => :active)
      end
      it "call Payola::CancelSubscription and redirect" do
        Payola::CancelSubscription.should_receive(:call)
        delete :destroy, guid: @subscription.guid
        # TODO : Figure out why this needs to be a hardcoded path.
        # Why doesn't subscription_path(@subscription) work?
        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
      end

      it "should redirect with an error if it can't cancel the subscription" do
        expect(Payola::CancelSubscription).to_not receive(:call)
        expect_any_instance_of(::ApplicationController).to receive(:payola_can_modify_subscription?).and_return(false)

        delete :destroy, guid: @subscription.guid
        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'You cannot modify this subscription.'
      end

      it "coerce the at_period_end param to a boolean, and pass it through to Payola::CancelSubscription" do
        Payola::CancelSubscription.should_receive(:call).with(instance_of(Payola::Subscription), at_period_end: true)
        delete :destroy, guid: @subscription.guid, at_period_end: 'true'
      end
    end

    describe '#change_plan' do
      before :each do
        @subscription = create(:subscription, state: :active, stripe_customer_id: 'MyString')
        @plan = create(:subscription_plan)
      end

      it "should call Payola::ChangeSubscriptionPlan and redirect" do
        expect(Payola::ChangeSubscriptionPlan).to receive(:call).with(@subscription, @plan)

        post :change_plan, guid: @subscription.guid, plan_class: @plan.plan_class, plan_id: @plan.id

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:notice]).to eq 'Subscription plan updated'
      end

      it "should show error if Payola::ChangeSubscriptionPlan fails" do
        StripeMock.prepare_error(Stripe::StripeError.new('There was a problem changing the subscription'))

        post :change_plan, guid: @subscription.guid, plan_class: @plan.plan_class, plan_id: @plan.id

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'There was a problem changing the subscription'
      end

      it "should redirect with an error if it can't update the subscription" do
        expect(Payola::ChangeSubscriptionPlan).to_not receive(:call)
        expect_any_instance_of(::ApplicationController).to receive(:payola_can_modify_subscription?).and_return(false)

        post :change_plan, guid: @subscription.guid, plan_class: @plan.plan_class, plan_id: @plan.id
        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'You cannot modify this subscription.'
      end
    end

    describe '#change_quantity' do
      before :each do
        @subscription = create(:subscription, state: :active, stripe_customer_id: 'MyString')
        @plan = create(:subscription_plan)
      end

      it "should call Payola::ChangeSubscriptionQuantity and redirect" do
        expect(Payola::ChangeSubscriptionQuantity).to receive(:call).with(@subscription, 5)

        post :change_quantity, guid: @subscription.guid, quantity: 5

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:notice]).to eq 'Subscription quantity updated'
      end

      it "should show error if Payola::ChangeSubscriptionQuantity fails" do
        StripeMock.prepare_error(Stripe::StripeError.new('There was a problem changing the subscription quantity'))

        post :change_quantity, guid: @subscription.guid, quantity: 5

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'There was a problem changing the subscription quantity'
      end

      it "should redirect with an error if it can't update the subscription" do
        expect(Payola::ChangeSubscriptionQuantity).to_not receive(:call)
        expect_any_instance_of(::ApplicationController).to receive(:payola_can_modify_subscription?).and_return(false)

        post :change_quantity, guid: @subscription.guid, quantity: 5
        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'You cannot modify this subscription.'
      end
    end

    describe "#update_card" do
      before :each do
        @subscription = create(:subscription, state: :active, stripe_customer_id: 'MyString')
        @plan = create(:subscription_plan)
      end

      it "should call UpdateCard and redirect" do
        expect(Payola::UpdateCard).to receive(:call).with(@subscription, 'tok_1234')

        post :update_card, guid: @subscription.guid, stripeToken: 'tok_1234'

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:notice]).to eq 'Card updated'
      end

      it "should show error if Payola::UpdateCare fails" do
        StripeMock.prepare_error(Stripe::StripeError.new('There was a problem updating the card'))

        post :update_card, guid: @subscription.guid, stripeToken: 'tok_1234'

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'There was a problem updating the card'
      end

      it "should redirect with an error" do
        expect(Payola::UpdateCard).to receive(:call).never
        expect_any_instance_of(::ApplicationController).to receive(:payola_can_modify_subscription?).and_return(false)

        post :update_card, guid: @subscription.guid, stripeToken: 'tok_1234'

        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'You cannot modify this subscription.'
      end
    end

  end
end
