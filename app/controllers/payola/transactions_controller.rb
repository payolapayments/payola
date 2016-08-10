module Payola
  class TransactionsController < ApplicationController
    include Payola::AffiliateBehavior
    include Payola::StatusBehavior
    include Payola::AsyncBehavior

    before_action :find_product_and_coupon, only: [:create]

    def show
      show_object(Sale)
    end

    def status
      object_status(Sale)
    end

    def create
      create_object(Sale, CreateSale, ProcessSale, :product, @product)
    end

    private
    def find_product_and_coupon
      find_product
      find_coupon
    end

    def find_product
      @product_class = Payola.sellables[params[:product_class]]

      raise ActionController::RoutingError.new('Not Found') unless @product_class && @product_class.sellable?

      @product = @product_class.find_by!(permalink: params[:permalink])
    end

    def find_coupon
      coupon_code = cookies[:cc] || params[:cc] || params[:coupon_code]
      @coupon = Coupon.where('lower(code) = lower(?)', coupon_code).first
      if @coupon && @coupon.active?
        cookies[:cc] = coupon_code
        @price = @product.price * (1 - @coupon.percent_off / 100.0)
      else
        @price = @product.price
      end
    end

  end
end
