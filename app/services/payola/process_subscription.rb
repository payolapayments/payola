module Payola
  class ProcessSubscription
    def self.call(guid)
      Subscription.find_by(guid: guid).process!
    end
  end
end
