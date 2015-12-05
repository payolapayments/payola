require 'spec_helper'

module Payola
  describe "#configure" do
    it "should pass the class back to the given block" do
      Payola.configure do |payola|
        expect(payola).to eq Payola
      end
    end
  end

  describe "keys" do
    it "should set publishable key from env" do
      ENV['STRIPE_PUBLISHABLE_KEY'] = 'some_key'
      Payola.reset!
      expect(Payola.publishable_key).to eq 'some_key'
    end

    it "should set secret key from env" do
      ENV['STRIPE_SECRET_KEY'] = 'some_secret'
      Payola.reset!
      expect(Payola.secret_key).to eq 'some_secret'
    end
  end

  describe "instrumentation" do
    it "should pass subscribe to StripeEvent" do
      expect(StripeEvent).to receive(:subscribe)
      Payola.subscribe('foo', 'blah')
    end
    it "should pass instrument to StripeEvent.backend" do
      expect(ActiveSupport::Notifications).to receive(:instrument)
      Payola.instrument('foo', 'blah')
    end
    it "should pass all to StripeEvent" do
      expect(StripeEvent).to receive(:all)
      Payola.all('blah')
    end
  end

  describe "#queue" do
    before do
      Payola.reset!

      Payola::Worker.registry ||= {}
      Payola::Worker.registry[:fake] = FakeWorker
    end

    describe "with symbol" do
      it "should find the correct background worker" do
        expect(FakeWorker).to receive(:call)

        Payola.background_worker = :fake
        Payola.queue!('blah')
      end

      it "should not find a background worker for an unknown symbol" do
        Payola.background_worker = :another_fake
        expect { Payola.queue!('blah') }.to raise_error(RuntimeError)
      end
    end

    describe "with callable" do
      it "should call the callable" do
        foo = nil
        
        Payola.background_worker = lambda do |sale|
          foo = sale
        end
  
        Payola.queue!('blah')
  
        expect(foo).to eq 'blah'
      end
    end

    describe "with nothing" do
      it "should call autofind" do
        expect(FakeWorker).to receive(:call).and_return(:true)
        expect(Payola::Worker).to receive(:autofind).and_return(FakeWorker)
        Payola.queue!('blah')
      end
    end
  end

  describe "#send_mail" do
    before do
      Payola.reset!

      Payola::Worker.registry ||= {}
      Payola::Worker.registry[:fake] = FakeWorker
      Payola.background_worker = :fake
    end

    it "should queue the SendMail service" do
      class FakeMailer < ActionMailer::Base
        def receipt(first, second)
        end
      end

      expect(FakeWorker).to receive(:call).with(Payola::SendMail, 'Payola::FakeMailer', 'receipt', 1, 2)
      Payola.send_mail(FakeMailer, :receipt, 1, 2)
    end
  end

  describe '#auto_emails' do
    before do
      Payola.reset!
    end

    it "should set up listeners for auto emails" do
      expect(Payola).to receive(:subscribe).with('payola.sale.finished').at_least(2)
      Payola.send_email_for :receipt, :admin_receipt
    end
  end

  describe "#secret_key_retriever" do
    it "should get called" do
      Payola.secret_key_retriever = lambda { |sale| 'foo' }
      expect(Payola.secret_key_for_sale('blah')).to eq 'foo'
    end
  end

  describe "#publishable_key_retriever" do
    it "should get called" do
      Payola.publishable_key_retriever = lambda { |sale| 'foo' }
      expect(Payola.publishable_key_for_sale('blah')).to eq 'foo'
    end
  end

  describe '#additional_charge_attributes' do
    it "should return a hash" do
      sale = double
      customer = double
      expect(Payola.additional_charge_attributes.call(sale, customer)).to eq({})
    end
  end

  describe "#create_stripe_plans" do
    it "defaults to true" do
      Payola.reset!
      expect(Payola.create_stripe_plans).to be true
    end
  end
end
