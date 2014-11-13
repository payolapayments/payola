require 'spec_helper'

module Payola
  describe SubscriptionsController do
    before do
      @plan = create(:subscription_plan)
      Payola.register_subscribable(@plan.class)
    end

    describe '#create' do
      it "should pass args to CreateSubscription and queue the job" do
        subscription = double
        subscription.should_receive(:save).and_return(true)
        subscription.should_receive(:guid).at_least(1).times.and_return(1)

        CreateSubscription.should_receive(:call).and_return(subscription)
        Payola.should_receive(:queue!)
        post :create, plan_class: @plan.plan_class, plan_id: @plan.id, use_route: :payola

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

          CreateSubscription.should_receive(:call).and_return(subscription)
          Payola.should_not_receive(:queue!)

          post :create, plan_class: @plan.plan_class, plan_id: @plan.id, use_route: :payola

          expect(response.status).to eq 400
          parsed_body = JSON.load(response.body)
          expect(parsed_body['error']).to eq 'done did broke'
        end
      end
    end

    describe '#status' do
      it "should return 404 if it can't find the subscription" do
        get :status, guid: 'doesnotexist', use_route: :payola
        expect(response.status).to eq 404
      end
      it "should return json with properties" do
        subscription = create(:subscription)
        get :status, guid: subscription.guid, use_route: :payola

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
        get :show, guid: subscription.guid, use_route: :payola

        expect(response).to redirect_to '/'
      end
    end

    describe '#destroy' do
      before :each do
        @subscription = create(:subscription, :state => :active)
      end
      it "call Payola::CancelSubscription and redirect" do
        Payola::CancelSubscription.should_receive(:call)
        delete :destroy, :guid => @subscription.guid, use_route: :payola
        # TODO : Figure out why this needs to be a hardcoded path.
        # Why doesn't subscription_path(@subscription) work?
        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
      end

      it "should redirect with an error if it can't cancel the subscription" do
        expect(Payola::CancelSubscription).to_not receive(:call)
        expect_any_instance_of(::ApplicationController).to receive(:payola_can_cancel_subscription?).and_return(false)

        delete :destroy, :guid => @subscription.guid, use_route: :payola
        expect(response).to redirect_to "/subdir/payola/confirm_subscription/#{@subscription.guid}"
        expect(request.flash[:alert]).to eq 'You cannot cancel this subscription.'
      end
    end

  end
end
