module Payola
  class TransactionsController < ApplicationController
    include Payola::AffiliateBehavior

    before_filter :find_product_and_coupon, only: [:create]

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
      create_params = params.permit!.merge(
        product: @product,
        coupon: @coupon,
        affiliate: @affiliate
      )

      @sale = CreateSale.call(create_params)

      if @sale.save
        Payola.queue!(Payola::ProcessSale, @sale.guid)
        render json: { guid: @sale.guid }
      else
        render json: { error: @sale.errors.full_messages.join(". ") }, status: 400
      end
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
      if @coupon
        cookies[:cc] = coupon_code
        @price = @product.price * (1 - @coupon.percent_off / 100.0)
      else
        @price = @product.price
      end
    end

  end
end
