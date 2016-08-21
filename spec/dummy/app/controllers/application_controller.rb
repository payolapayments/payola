class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def payola_can_modify_subscription?(subscription)
    true
  end

  def payola_can_modify_customer?(customer)
    true
  end
end
