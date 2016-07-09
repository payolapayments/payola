module ParamsHelper
  def permitted_params(params)
    ActionController::Parameters.new(params).permit!
  end
end

RSpec.configure do |config|
  config.include ParamsHelper, type: :controller
end
