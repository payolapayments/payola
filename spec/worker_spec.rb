require 'spec_helper'

module Payola

  class TestService
    def self.call(thing)
      thing.guid
    end
  end

  describe Worker::Sidekiq do
    before do
      module ::Sidekiq
        module Worker
          def perform_async
          end
        end
      end
    end

    describe "#can_run?" do
      it "should return true if ::Sidekiq::Worker is defined" do
        expect(Payola::Worker::Sidekiq.can_run?).to be_truthy
      end
    end

    describe "#call" do
      it "should call perform_async" do
        Payola::Worker::Sidekiq.should_receive(:perform_async)
        Payola::Worker::Sidekiq.call(Payola::TestService, double)
      end
    end
  end

  describe Worker::SuckerPunch do
    describe "#can_run?" do
      it "should return true if SuckerPunch is defined" do
        expect(Payola::Worker::SuckerPunch.can_run?).to be_truthy
      end
    end

    describe "#call" do
      it "should call async" do
        worker = double
        expect(Payola::Worker::SuckerPunch).to receive(:new).and_return(worker)
        expect(worker).to receive(:async).and_return(worker)
        expect(worker).to receive(:perform)
        Payola::Worker::SuckerPunch.call(Payola::TestService, double)
      end
    end
  end

  describe Worker::ActiveJob do
    before do
      module ::ActiveJob
        module Core; end
      end
    end

    describe "#can_run?" do
      it "should return true if ::ActiveJob::Core is defined" do
        expect(Payola::Worker::ActiveJob.can_run?).to be_truthy
      end
    end

    describe "#call" do
      it "should call perform_later" do
        Payola::Worker::ActiveJob.should_receive(:perform_later)
        Payola::Worker::ActiveJob.call(Payola::TestService, double)
      end
    end
  end
end
