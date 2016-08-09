module Payola
  class CardsController < ApplicationController

    before_action :check_modify_permissions, only: [:create, :destroy]

    def create
      if params[:customer_id].present? && params[:stripeToken].present?
        Payola::CreateCard.call(params[:customer_id], params[:stripeToken])
        flash_options = { notice: t('payola.cards.created') }
      else
        flash_options = { alert: t('payola.cards.not_created') }
      end
      redirect_to return_to, flash: flash_options
    end

    def destroy
      if params[:id].present? && params[:customer_id].present?
        Payola::DestroyCard.call(params[:id], params[:customer_id])
        flash_options = { notice: t('payola.cards.destroyed') }
      else
        flash_options = { alert: t('payola.cards.not_destroyed') }
      end
      redirect_to return_to, flash: flash_options
    end

    private

    def check_modify_permissions
      if self.respond_to?(:payola_can_modify_customer?)
        redirect_to(
          return_to,
          alert: t('payola.cards.not_authorized')
        ) and return unless self.payola_can_modify_customer?(params[:customer_id])
      else
        raise NotImplementedError.new("Please implement ApplicationController#payola_can_modify_customer?")
      end
    end

  end
end
