module Payola
  class ProcessSale
    def self.call(guid)
      Sale.find_by(guid: guid).process!
    end
  end
end
