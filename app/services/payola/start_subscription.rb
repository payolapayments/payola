module Payola
  class StartSubscription
    attr_reader :subscription, :secret_key
    
    def self.call(subscription)
      subscription.save!
      secret_key = Payola.secret_key_for_sale(subscription)

      new(subscription, secret_key).run
    end

    def initialize(subscription, secret_key)
      @subscription = subscription
      @secret_key = secret_key
    end

    def run
      begin
        subscription.verify_charge!

        customer = find_or_create_customer

        create_params = {
          plan: subscription.plan.stripe_id,
          quantity: subscription.quantity
        }
        create_params[:coupon] = subscription.coupon if subscription.coupon.present?
        stripe_sub = customer.subscriptions.create(create_params)

        card = customer.cards.data.first
        subscription.update_attributes(
          stripe_id:          stripe_sub.id,
          stripe_customer_id: customer.id,
          card_last4:         card.last4,
          card_expiration:    Date.new(card.exp_year, card.exp_month, 1),
          card_type:          card.respond_to?(:brand) ? card.brand : card.type
        )
        subscription.activate!
      rescue Stripe::StripeError, RuntimeError => e
        subscription.update_attributes(error: e.message)
        subscription.fail!
      end

      subscription
    end

    def find_or_create_customer
      subs = Subscription.where(owner: subscription.owner) if subscription.owner
      if subs && subs.length > 1
        first_sub = subs.first
        customer_id = first_sub.stripe_customer_id
        return Stripe::Customer.retrieve(customer_id, secret_key)
      else
        customer_create_params = {
          card:  subscription.stripe_token,
          email: subscription.email
        }
  
        customer = Stripe::Customer.create(customer_create_params, secret_key)
      end

      if subscription.setup_fee.present?
        plan = subscription.plan
        description = plan.try(:setup_fee_description, subscription) || 'Setup Fee'
        Stripe::InvoiceItem.create({
          customer: customer.id,
          amount: subscription.setup_fee,
          currency: subscription.currency,
          description: description
        }, secret_key)
      end

      customer
    end
  end

end
