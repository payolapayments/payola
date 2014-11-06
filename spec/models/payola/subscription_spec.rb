require 'spec_helper'

module Payola
  describe Subscription do

    describe "validations" do
      it "should validate" do
        subscription = build(:subscription)
        expect(subscription.valid?).to be true
      end

      it "should validate plan" do
        subscription = build(:subscription, plan: nil)
        expect(subscription.valid?).to be false
      end

    end

  end
end
