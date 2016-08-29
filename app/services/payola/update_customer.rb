module Payola
  class UpdateCustomer
    def self.call(stripe_customer_id, options)
      secret_key = Payola.secret_key
      customer = Stripe::Customer.retrieve(stripe_customer_id, secret_key)
      customer.save(options.to_h)
    end
  end
end
