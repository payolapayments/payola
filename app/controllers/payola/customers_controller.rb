module Payola
  class CustomersController < ApplicationController
     
    before_filter :check_modify_permissions, only: [:update]
 
    def update
      if params[:id].present?
        Payola::UpdateCustomer.call(params[:id], customer_params)
        redirect_to return_to, notice: "Succesfully updated customer"
      else
        redirect_to return_to, alert: "Could not update customer"
      end  
    end

    private

    # Only including default_source for now, though other attributes can be used 
    # (https://stripe.com/docs/api#update_customer)
    def customer_params
      params.require(:customer).permit(:default_source)
    end

    def check_modify_permissions
      if self.respond_to?(:payola_can_modify_customer?)
        redirect_to(
          return_to,
          alert: "You cannot modify this customer."
        ) and return unless self.payola_can_modify_customer?(params[:id])
      end
    end

    def return_to
      params[:return_to] || :back
    end

  end
end
