require 'spec_helper'

module Payola
  describe Worker do
    describe "#find" do
      it "should find a worker class in the registry"
    end

    describe "#autofind" do
      it "should find a worker if there is one available"
    end

    describe Worker::Sidekiq do
      describe "#can_run?" do
        it "should return true if ::Sidekiq::Worker is defined"
      end

      describe "#call" do
        it "should include ::Sidekiq::Worker"
        it "should call perform_async"
      end
    end
  end
end
