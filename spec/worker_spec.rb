require 'spec_helper'

module Payola

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
        sale = double()
        sale.should_receive(:guid).and_return('blah')
        Payola::Worker::Sidekiq.call(sale)
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
        sale = double()
        sale.should_receive(:guid).and_return('blah')
        Payola::Worker::ActiveJob.call(sale)
      end
    end
  end
end
