module Payola
  class DestroyCard
    def self.call(card_id, stripe_customer_id)
      secret_key = Payola.secret_key
      customer = Stripe::Customer.retrieve(stripe_customer_id, secret_key)
      customer.sources.retrieve(card_id).delete()
    end
  end
end
