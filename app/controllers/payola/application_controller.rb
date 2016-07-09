module Payola
  class ApplicationController < ::ApplicationController
    helper PriceHelper

    private

    def return_to
      return params[:return_to] if params[:return_to]
      request.headers["Referer"] or raise ActionController::RedirectBackError
    end

  end
end
