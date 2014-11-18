module Payola
  module AsyncBehavior
    extend ActiveSupport::Concern

    def show_object(object_class)
      object = object_class.find_by!(guid: params[:guid])
      redirector = object.redirector

      new_path = redirector.respond_to?(:redirect_path) ? redirector.redirect_path(object) : '/'
      redirect_to new_path
    end

    def object_status(object_class)
      object = object_class.find_by(guid: params[:guid])
      render nothing: true, status: 404 and return unless object
      render json: {guid: object.guid, status: object.state, error: object.error}
    end

    def create_object(object_class, object_creator_class, object_processor_class)
      create_params = params.permit!.merge(
        plan: @plan,
        coupon: @coupon,
        affiliate: @affiliate
      )

      object = object_creator_class.call(create_params)

      if object.save
        Payola.queue!(object_processor_class, object.guid)
        render json: { guid: object.guid }
      else
        render json: { error: object.errors.full_messages.join(". ") }, status: 400
      end
    end
  end
end
