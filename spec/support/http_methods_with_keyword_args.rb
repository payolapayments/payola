if Rails::VERSION::MAJOR == 4

  module HTTPMethodsWithKeywordArgs
    def get(action, params: nil, headers: nil)
      super(action, params, headers)
    end

    def post(action, params: nil, headers: nil)
      super(action, params, headers)
    end

    def delete(action, params: nil, headers: nil)
      super(action, params, headers)
    end
  end

  RSpec.configure do |config|
    config.include HTTPMethodsWithKeywordArgs, type: :controller
  end

end
