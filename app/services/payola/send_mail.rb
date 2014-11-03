module Payola
  class SendMail
    def self.call(mailer, method, *args)
      mailer.safe_constantize.send(method, *args).deliver
    end
  end
end
