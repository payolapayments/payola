module Payola
  class ProcessRefund
    def self.call(guid)
      sale = Sale.find_by(guid: guid)
      
      begin
        secret_key = Payola.secret_key
        Stripe.api_key = secret_key
        charge = Stripe::Charge.retrieve(sale.stripe_id)
        charge.refund

        sale.refund!
      rescue Stripe::InvalidRequestError, Stripe::StripeError, RuntimeError => e
        sale.errors[:base] << e.message
      end

      sale
    end
  end
end
