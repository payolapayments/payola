module Payola
  class CreateCard
    def self.call(stripe_customer_id, token)
      secret_key = Payola.secret_key
      card_fingerprint = Stripe::Token.retrieve(token, secret_key).try(:card).try(:fingerprint)
      customer = Stripe::Customer.retrieve(stripe_customer_id, secret_key)

      unless customer.sources.select{|source| source.fingerprint == card_fingerprint}.any?
        customer.sources.create(source: token)
      end
    end
  end
end
