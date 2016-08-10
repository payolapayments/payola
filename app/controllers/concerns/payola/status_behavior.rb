module Payola
  module StatusBehavior
    extend ActiveSupport::Concern

    def render_payola_status(object)
      head :not_found and return unless object

      errors = ([object.error.presence] + object.errors.full_messages).compact.to_sentence

      render json: {
        guid:   object.guid,
        status: object.state,
        error:  errors.presence
      }, status: errors.blank? ? 200 : 400
    end
  end
end
