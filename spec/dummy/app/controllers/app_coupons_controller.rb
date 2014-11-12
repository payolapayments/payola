class AppCouponsController < ApplicationController
  before_action :set_app_coupon, only: [:show, :edit, :update, :destroy]

  # GET /app_coupons
  def index
    @app_coupons = AppCoupon.all
  end

  # GET /app_coupons/1
  def show
  end

  # GET /app_coupons/new
  def new
    @app_coupon = AppCoupon.new
  end

  # GET /app_coupons/1/edit
  def edit
  end

  # POST /app_coupons
  def create
    @app_coupon = AppCoupon.new(app_coupon_params)

    if @app_coupon.save
      redirect_to @app_coupon, notice: 'App coupon was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /app_coupons/1
  def update
    if @app_coupon.update(app_coupon_params)
      redirect_to @app_coupon, notice: 'App coupon was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /app_coupons/1
  def destroy
    @app_coupon.destroy
    redirect_to app_coupons_url, notice: 'App coupon was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app_coupon
      @app_coupon = AppCoupon.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def app_coupon_params
      params.require(:app_coupon).permit(:percent_off, :amount_off, :currency, :duration, :duration_in_months, :stripe_id, :max_redemptions, :redeem_by)
    end
end
