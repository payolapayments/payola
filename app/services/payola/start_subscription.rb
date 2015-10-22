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
          quantity: subscription.quantity,
          tax_percent: subscription.tax_percent
        }
        create_params[:trial_end] = subscription.trial_end.to_i if subscription.trial_end.present?
        create_params[:coupon] = subscription.coupon if subscription.coupon.present?
        stripe_sub = customer.subscriptions.create(create_params)

        subscription.update_attributes(
          stripe_id:             stripe_sub.id,
          stripe_customer_id:    customer.id,
          current_period_start:  Time.at(stripe_sub.current_period_start),
          current_period_end:    Time.at(stripe_sub.current_period_end),
          ended_at:              stripe_sub.ended_at ? Time.at(stripe_sub.ended_at) : nil,
          trial_start:           stripe_sub.trial_start ? Time.at(stripe_sub.trial_start) : nil,
          trial_end:             stripe_sub.trial_end ? Time.at(stripe_sub.trial_end) : nil,
          canceled_at:           stripe_sub.canceled_at ? Time.at(stripe_sub.canceled_at) : nil,
          quantity:              stripe_sub.quantity,
          stripe_status:         stripe_sub.status,
          cancel_at_period_end:  stripe_sub.cancel_at_period_end
        )

        card = customer.sources.data.first
        unless card.nil?
          subscription.update_attributes(
            card_last4:          card.last4,
            card_expiration:     Date.new(card.exp_year, card.exp_month, 1),
            card_type:           card.respond_to?(:brand) ? card.brand : card.type,
          )
        end
        
        subscription.activate!
      rescue Stripe::StripeError, RuntimeError => e
        subscription.update_attributes(error: e.message)
        subscription.fail!
      end

      subscription
    end

    def find_or_create_customer
      if subscription.stripe_customer_id.present?    
        customer = Stripe::Customer.retrieve(subscription.stripe_customer_id, secret_key)
        return customer unless customer.try(:deleted)
      end

      subs = Subscription.where(owner: subscription.owner).where("state in ('active', 'canceled')") if subscription.owner

      if subs && subs.length >= 1
        first_sub = subs.first
        customer_id = first_sub.stripe_customer_id
        unless customer_id.blank?
          customer = Stripe::Customer.retrieve(customer_id, secret_key)
          return customer unless customer.try(:deleted)
        end
      end

      unless subscription.stripe_token.present?
        raise "stripeToken required for new customer subscription"
      end

      customer_create_params = {
        source: subscription.stripe_token,
        email:  subscription.email
      }

      customer = Stripe::Customer.create(customer_create_params, secret_key)

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
