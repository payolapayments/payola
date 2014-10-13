module Payola
  class ChargeCard
    def self.call(sale)
      sale.save!
      secret_key = Payola.secret_key_for_sale(sale)

      begin
        Payola.charge_verifier(sale)
        
        customer = Stripe::Customer.create({
          card: sale.stripe_token,
          email: sale.email
        }, secret_key)
  
        charge = Stripe::Charge.create({
          amount: sale.amount,
          currency: "usd",
          customer: customer.id,
          description: sale.guid,
        }, secret_key)
  
        if charge.respond_to?(:fee)
          fee = charge.fee
        else
          balance = Stripe::BalanceTransaction.retrieve(charge.balance_transaction, secret_key)
          fee = balance.fee
        end
  
        sale.update_attributes(
          stripe_id:          charge.id,
          stripe_customer_id: customer.id,
          card_last4:         charge.card.last4,
          card_expiration:    Date.new(charge.card.exp_year, charge.card.exp_month, 1),
          card_type:          charge.card.respond_to?(:brand) ? charge.card.brand : charge.card.type,
          fee_amount:         fee
        )
        sale.finish!
      rescue Stripe::StripeError => e
        sale.update_attributes(error: e.message)
        sale.fail!
      rescue RuntimeError => e
        sale.update_attributes(error: e.message)
        sale.fail!
      end

      sale
    end

  end
end
