module Payola
  class AdminMailer < ActionMailer::Base
    helper Payola::PriceHelper

    def receipt(sale_guid)
      send_admin_mail(sale_guid)
    end

    def refund(sale_guid)
      send_admin_mail(sale_guid)
    end

    def dispute(sale_guid)
      send_admin_mail(sale_guid)
    end

    def failure(sale_guid)
      send_admin_mail(sale_guid)
    end

    def send_admin_mail(sale_guid)
      ActiveRecord::Base.connection_pool.with_connection do
        @sale = Payola::Sale.find_by(guid: sale_guid)
        @product = @sale.product
        mail(from: Payola.support_email, to: Payola.support_email)
      end
    end
  end
end
