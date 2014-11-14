module Payola
  class InvoiceFailed
    def self.call(event)
      invoice = event.data.object

      subscription = Payola::Subscription.find_by!(stripe_id: invoice.subscription)
      secret_key = Payola.secret_key_for_sale(subscription)

      stripe_sub = Stripe::Customer.retrieve(subscription.stripe_customer_id, secret_key).subscriptions.retrieve(invoice.subscription, secret_key)
      subscription.sync_with!(stripe_sub)

      sale = Payola::Sale.new do |s|
        s.email = subscription.email
        s.state = 'processing'
        s.owner = subscription
        s.product = subscription.plan
        s.stripe_token = 'invoice'
        s.amount = invoice.total
        s.currency = invoice.currency
      end

      charge = Stripe::Charge.retrieve(invoice.charge, secret_key)

      sale.stripe_id  = charge.id
      sale.card_type  = charge.card.respond_to?(:brand) ? charge.card.brand : charge.card.type
      sale.card_last4 = charge.card.last4

      if charge.respond_to?(:fee)
        sale.fee_amount = charge.fee
      else
        balance = Stripe::BalanceTransaction.retrieve(charge.balance_transaction, secret_key)
        sale.fee_amount = balance.fee
      end

      sale.error = charge.failure_message
      sale.save!
      sale.fail!

      sale
    end
  end
end
