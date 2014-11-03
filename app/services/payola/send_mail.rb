module Payola
  class SendMail
    def self.call(mailer, method, *args)
      mailer.send(method, *args).deliver
    end
  end
end
