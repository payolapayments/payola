module Payola
  class CardsController < ApplicationController
  
    before_filter :check_modify_permissions, only: [:create, :destroy]
    
    def create
      if params[:customer_id].present? && params[:stripeToken].present?
        Payola::CreateCard.call(params[:customer_id], params[:stripeToken])
        redirect_to return_to, notice: "Succesfully created new card"
      else
        redirect_to return_to, alert: "Could not create new card"
      end  
    end

    def destroy
      if params[:id].present? && params[:customer_id].present?
        Payola::DestroyCard.call(params[:id], params[:customer_id])
        redirect_to return_to, notice: "Succesfully removed the card"
      else
        redirect_to return_to, alert: "Could not remove the card"
      end  
    end

    private

    def check_modify_permissions
      if self.respond_to?(:payola_can_modify_customer?)
        redirect_to(
          return_to,
          alert: "You cannot modify this customer."
        ) and return unless self.payola_can_modify_customer?(params[:customer_id])
      end
    end

    def return_to
      params[:return_to] || :back
    end

  end
end
