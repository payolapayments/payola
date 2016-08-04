module Payola
  class CouponsController < ApplicationController
    before_filter :check_modify_permissions, only: [:create, :destroy]

    def create
      @coupon = Coupon.new(coupon_params)

      if @coupon.save
        redirect_to return_to, notice: "Succesfully created new coupon"
      else
        redirect_to return_to, alert: "Could not create new coupon"
      end  
    end

    def destroy
      @coupon = Coupon.find(params[:id])

      if @coupon.destroy
        redirect_to return_to, notice: "Succesfully removed the coupon"
      else
        redirect_to return_to, alert: "Could not remove the coupon"
      end  
    end

    private

    def check_modify_permissions
      if self.respond_to?(:payola_can_modify_coupon?)
        redirect_to(
          return_to,
          alert: "You cannot modify this coupon."
        ) and return unless self.payola_can_modify_coupon?(params[:id])
      end
    end

    def coupon_params
      params.require(:coupon)
        .permit(
          :id,
          :code,
          :active,
          :percent_off,
          :amount_off,
          :duration,
          :duration_in_months,
          :max_redemptions,
          :redeem_by,
          :currency
        )
    end

    def return_to
      params[:return_to] || :back
    end
  end
end
