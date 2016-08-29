module Payola
  class UpdateCustomer
    def self.call(stripe_customer_id, options)
      secret_key = Payola.secret_key
      Stripe.api_key = secret_key
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      customer.save(options.to_h)
    end
  end
end
