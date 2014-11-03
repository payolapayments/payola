module Payola
  module Worker
    class BaseWorker
      def perform(klass, *args)
        klass.safe_constantize.call(*args)
      end
    end
  end
end
