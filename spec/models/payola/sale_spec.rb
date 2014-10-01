require 'spec_helper'

module Payola
  describe Sale do
    describe "validations" do
      it "should validate email"
      it "should validate product"
      it "should validate stripe_token"
    end

    describe "#guid" do
      it "should generate a unique guid"
    end

    describe "#process!" do
      it "should charge the card"
    end

    describe "#finish" do
      it "should instrument finish"
    end

    describe "#fail" do
      it "should instrument fail"
    end

    describe "#refund" do
      it "should instrument refund"
    end
  end
end
