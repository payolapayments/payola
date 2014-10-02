require 'spec_helper'

module Payola
  describe StripeWebhook do
    it "should validate" do
      s = StripeWebhook.new(stripe_id: 'test_id')
      expect(s.valid?).to be true
    end

    it "should validate stripe_id" do
      s = StripeWebhook.create(stripe_id: 'test_id')
      s2 = StripeWebhook.new(stripe_id: 'test_id')

      expect(s2.valid?).to be false
    end
  end
end
