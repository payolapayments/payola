require 'spec_helper'

module Payola
  describe "#configure" do
    it "should pass the class back to the given block"
  end

  describe "keys" do
    it "should set publishable key from env"
    it "should set secret key from env"
  end

  describe "instrumentation" do
    it "should pass subscribe to StripeEvent"
    it "should pass instrument to StripeEvent.backend"
    it "should pass all to StripeEvent"
  end

  describe "#queue" do
    describe "with symbol" do
      it "should find the correct background worker"
      it "should not find a background worker for an unknown symbol"
    end

    describe "with callable" do
      it "should call the callable"
    end

    describe "with nothing" do
      it "should call autofind"
    end
  end

  describe "#event_filter" do
    it "should get called"
  end

  describe "#secret_key_retriever" do
    it "should get called"
  end
end
