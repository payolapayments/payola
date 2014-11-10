module Payola
  class InvoicePaid
    def self.call(event)
      invoice = event.data.object

      return unless invoice.charge

      subscription = Payola::Subscription.find_by!(stripe_id: invoice.subscription)

      sale = Payola::Sale.new do |s|
        s.email = subscription.email
        s.state = 'processing'
        s.owner = subscription
        s.product = subscription.plan
        s.stripe_token = 'invoice'
        s.amount = invoice.total
        s.currency = invoice.currency
      end

      charge = Stripe::Charge.retrieve(invoice.charge, Payola.secret_key_for_sale(sale))

      sale.stripe_id = charge.id

      if charge.respond_to?(:fee)
        sale.fee_amount = charge.fee
      else
        balance = Stripe::BalanceTransaction.retrieve(charge.balance_transaction, secret_key)
        sale.fee_amount = balance.fee
      end

      sale.save!
      sale.finish!

      sale
    end
  end
end
