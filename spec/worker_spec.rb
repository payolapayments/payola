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
end
