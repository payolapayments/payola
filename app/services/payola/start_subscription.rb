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

        method = customer.sources.data.first
        if method.is_a? Stripe::Card
          card = method
          subscription.update_attributes(
            card_last4:          card.last4,
            card_expiration:     Date.new(card.exp_year, card.exp_month, 1),
            card_type:           card.respond_to?(:brand) ? card.brand : card.type,
          )
        elsif method.is_a? Stripe::BankAccount
          bank = method
          subscription.update_attributes(
            card_last4:          bank.last4,
            card_expiration:     Date.today + 365,
            card_type:           bank.bank_name
          )
        else
          # Unsupported payment type
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
        # If an existing Stripe customer id is specified, use it
        stripe_customer_id = subscription.stripe_customer_id
      elsif subscription.owner
        # Look for an existing successful Subscription for the same owner, and use its Stripe customer id
        stripe_customer_id = Subscription.where(owner: subscription.owner).where("stripe_customer_id IS NOT NULL").where("state in ('active', 'canceled')").pluck(:stripe_customer_id).first
      end

      if stripe_customer_id
        # Retrieve the customer from Stripe and use it for this subscription
        customer = Stripe::Customer.retrieve(stripe_customer_id, secret_key)

        unless customer.try(:deleted)
          if customer.default_source.nil? && subscription.stripe_token.present?
            customer.source = subscription.stripe_token
            customer.save
          end

          return customer
        end
      end

      if subscription.plan.amount > 0 and not subscription.stripe_token.present?
        raise "stripeToken required for new customer with paid subscription"
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
