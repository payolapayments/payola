module Payola
  module Worker
    class BaseWorker
      def perform(guid)
        Sale.where(guid: guid).first.process!
      end
    end
  end
end
