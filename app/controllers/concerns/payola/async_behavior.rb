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
      render_payola_status(object)
    end

    def create_object(object_class, object_creator_class, object_processor_class, product_key, product)
      create_params = if object_class == Subscription
        params.permit!.merge(
          product_key => product,
          coupon: @coupon,
          quantity: @quantity,
          affiliate: @affiliate
        )
      else
        params.permit!.merge(
          product_key => product,
          coupon: @coupon,
          affiliate: @affiliate
        )
      end

      object = object_creator_class.call(create_params)

      if object.save && object_processor_class.present?
        Payola.queue!(object_processor_class, object.guid)
      end

      render_payola_status(object)
    end
  end
end
