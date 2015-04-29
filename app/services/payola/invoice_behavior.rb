require 'active_support/concern'

module Payola
  module InvoiceBehavior
    extend ActiveSupport::Concern

    module ClassMethods
      def create_sale_from_event(event)
        invoice = event.data.object

        return unless invoice.charge

        subscription = Payola::Subscription.find_by!(stripe_id: invoice.subscription)
        secret_key = Payola.secret_key_for_sale(subscription)

        stripe_sub = Stripe::Customer.retrieve(subscription.stripe_customer_id, secret_key).subscriptions.retrieve(invoice.subscription, secret_key)
        subscription.sync_with!(stripe_sub)

        sale = create_sale(subscription, invoice)

        charge = Stripe::Charge.retrieve(invoice.charge, secret_key)

        update_sale_with_charge(sale, charge, secret_key)

        return sale, charge
      end

      def create_sale(subscription, invoice)
        Payola::Sale.new do |s|
          s.email = subscription.email
          s.state = 'processing'
          s.owner = subscription
          s.product = subscription.plan
          s.stripe_token = 'invoice'
          s.amount = invoice.total
          s.currency = invoice.currency
        end
      end

      def update_sale_with_charge(sale, charge, secret_key)
        sale.stripe_id  = charge.id
        sale.card_type  = charge.source.brand
        sale.card_last4 = charge.source.last4

        if charge.respond_to?(:fee)
          sale.fee_amount = charge.fee
        elsif !charge.balance_transaction.nil?
          balance = Stripe::BalanceTransaction.retrieve(charge.balance_transaction, secret_key)
          sale.fee_amount = balance.fee
        end
      end
    end

  end
end
