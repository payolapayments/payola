module Payola
  module AffiliateBehavior
    extend ActiveSupport::Concern

    included do
      before_action :find_affiliate
    end

    def find_affiliate
      affiliate_code = cookies[:aff] || params[:aff]
      @affiliate = Affiliate.where('lower(code) = lower(?)', affiliate_code).first
      if @affiliate
        cookies[:aff] = affiliate_code
      end
    end
  end
end
