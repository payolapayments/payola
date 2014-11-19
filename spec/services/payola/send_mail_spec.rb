require 'spec_helper'

module Payola

  class TestMailer < ActionMailer::Base
    def test_mail(to, text)
      mail(
        to: to,
        from: 'from@example.com',
        body: text
      )
    end
  end
  
  describe SendMail do
    describe "#call" do
      it "should send a mail" do
        mail = double
        expect(TestMailer).to receive(:test_mail).with('to@example.com', 'Some Text').and_return(mail)
        expect(mail).to receive(:deliver)
        Payola::SendMail.call('Payola::TestMailer', 'test_mail', 'to@example.com', 'Some Text')
      end
    end
  end
end
