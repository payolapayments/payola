module Payola
  class ReceiptMailer < ActionMailer::Base
    add_template_helper ::ApplicationHelper
    helper Payola::PriceHelper

    def receipt(sale_guid)
      ActiveRecord::Base.connection_pool.with_connection do
        @sale = Payola::Sale.find_by(guid: sale_guid)
        @product = @sale.product

        if Payola.pdf_receipt
          require 'docverter'

          pdf = Docverter::Conversion.run do |c|
            c.from = 'html'
            c.to = 'pdf'
            c.content = render_to_string('payola/receipt_mailer/receipt_pdf.html')
          end
          attachments["receipt-#{@sale.guid}.pdf"] = pdf
        end

        mail_params = {
          to: @sale.email,
          from: Payola.support_email,
          subject: @product.respond_to?(:receipt_subject) ? @product.receipt_subject(@sale) : 'Purchase Receipt',
        }

        if @product.respond_to?(:receipt_from_address)
          mail_params[:from] = @product.receipt_from_address(@sale)
        end

        mail(mail_params)
      end
    end

    def refund(sale_guid)
      ActiveRecord::Base.connection_pool.with_connection do
        @sale = Payola::Sale.find_by(guid: sale_guid)
        @product = @sale.product

        mail_params = {
          to: @sale.email,
          from: Payola.support_email,
          subject: @product.respond_to?(:refund_subject) ? @product.refund_subject(@sale) : 'Refund Confirmation',
        }

        if @product.respond_to?(:refund_from_address)
          mail_params[:from] = @product.refund_from_address(@sale)
        end

        mail(mail_params)
      end
    end

  end
end
