module Payola
  module Worker
    class BaseWorker
      def perform(klass, *args)
        klass.call(*args)
      end
    end
  end
end
