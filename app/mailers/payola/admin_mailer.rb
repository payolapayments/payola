module Payola
  class AdminMailer < ActionMailer::Base
    def receipt(sale_guid)
      ActiveRecord::Base.connection_pool.with_connection do
        @sale = Payola::Sale.find_by(guid: sale_guid)
        @product = @sale.product
        mail(from: Payola.support_email, to: Payola.support_email)
      end
    end

    def refund(sale_guid)
      ActiveRecord::Base.connection_pool.with_connection do
        @sale = Payola::Sale.find_by(guid: sale_guid)
        @product = @sale.product
        mail(from: Payola.support_email, to: Payola.support_email)
      end
    end

    def dispute(sale_guid)
      ActiveRecord::Base.connection_pool.with_connection do
        @sale = Payola::Sale.find_by(guid: sale_guid)
        @product = @sale.product
        mail(from: Payola.support_email, to: Payola.support_email)
      end
    end

    def failure(sale_guid)
      ActiveRecord::Base.connection_pool.with_connection do
        @sale = Payola::Sale.find_by(guid: sale_guid)
        @product = @sale.product
        mail(from: Payola.support_email, to: Payola.support_email)
      end
    end
  end
end
