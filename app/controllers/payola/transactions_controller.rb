module Payola
  class TransactionsController < ApplicationController
    before_filter :find_product_and_coupon_and_affiliate, only: [:create]

    def show
      sale = Sale.find_by!(guid: params[:guid])
      product = sale.product

      new_path = product.respond_to?(:redirect_path) ? product.redirect_path(sale) : '/'
      redirect_to new_path
    end

    def status
      @sale = Sale.where(guid: params[:guid]).first
      render nothing: true, status: 404 and return unless @sale
      render json: {guid: @sale.guid, status: @sale.state, error: @sale.error}
    end

    def create
      create_params = sale_params.merge(
        product: @product,
        coupon: @coupon,
        affiliate: @affiliate
        )

      @sale = CreateSale.call(create_params)

      if @sale.save
        Payola.queue!(@sale)
        render json: { guid: @sale.guid }
      else
        render json: { error: @sale.errors.full_messages.join(". ") }, status: 400
      end
    end

    private
    def find_product_and_coupon_and_affiliate
      @product_class = Payola.sellables[params[:product_class]]

      raise ActionController::RoutingError.new('Not Found') unless @product_class && @product_class.sellable?

      @product = @product_class.find_by!(permalink: params[:permalink])
      coupon_code = cookies[:cc] || params[:cc] || params[:coupon_code]

      @coupon = Coupon.where('lower(code) = lower(?)', coupon_code).first
      if @coupon
        cookies[:cc] = coupon_code
        @price = @product.price * (1 - @coupon.percent_off / 100.0)
      else
        @price = @product.price
      end

      affiliate_code = cookies[:aff] || params[:aff]
      @affiliate = Affiliate.where('lower(code) = lower(?)', affiliate_code).first
      if @affiliate
        cookies[:aff] = affiliate_code
      end

    end

    def sale_params
      params.slice(:stripeToken, :stripe_token, :stripeTokenType, :stripeEmail, :product_class, :permalink)
    end

  end
end
