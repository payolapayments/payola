var PayolaSubscriptionForm = {
    initialize: function() {
        $(document).off('submit.payola-subscription-form').on(
            'submit.payola-subscription-form', '.payola-subscription-form',
            function() {
                return PayolaSubscriptionForm.handleSubmit($(this));
            }
        );
    },

    handleSubmit: function(form) {
        $(form).find(':submit').prop('disabled', true);
        $('.payola-spinner').show();
        Stripe.card.createToken(form, function(status, response) {
            PayolaSubscriptionForm.stripeResponseHandler(form, status, response);
        });
        return false;
    },

    stripeResponseHandler: function(form, status, response) {
        if (response.error) {
            PayolaSubscriptionForm.showError(form, response.error.message);
        } else {
            var email = form.find("[data-payola='email']").val();
            var coupon = form.find("[data-payola='coupon']").val();
            var quantity = form.find("[data-payola='quantity']").val();

            var base_path = form.data('payola-base-path');
            var plan_type = form.data('payola-plan-type');
            var plan_id = form.data('payola-plan-id');

            var data_form = $('<form></form>');
            data_form.append($('<input type="hidden" name="stripeToken">').val(response.id));
            data_form.append($('<input type="hidden" name="stripeEmail">').val(email));
            data_form.append($('<input type="hidden" name="coupon">').val(coupon));
            data_form.append($('<input type="hidden" name="quantity">').val(quantity));
            data_form.append(PayolaSubscriptionForm.authenticityTokenInput());
            $.ajax({
                type: "POST",
                url: base_path + "/subscribe/" + plan_type + "/" + plan_id,
                data: data_form.serialize(),
                success: function(data) { PayolaSubscriptionForm.poll(form, 60, data.guid, base_path); },
                error: function(data) { PayolaSubscriptionForm.showError(form, jQuery.parseJSON(data.responseText).error); }
            });
        }
    },

    poll: function(form, num_retries_left, guid, base_path) {
        if (num_retries_left === 0) {
            PayolaSubscriptionForm.showError(form, "This seems to be taking too long. Please contact support and give them transaction ID: " + guid);
        }
        var handler = function(data) {
            if (data.status === "active") {
                form.append($('<input type="hidden" name="payola_subscription_guid"></input>').val(guid));
                form.append(PayolaSubscriptionForm.authenticityTokenInput());
                form.get(0).submit();
            } else {
                setTimeout(function() { PayolaSubscriptionForm.poll(form, num_retries_left - 1, guid, base_path); }, 500);
            }
        };
        var errorHandler = function(jqXHR){
          var responseJSON = jQuery.parseJSON(jqXHR.responseText);
          if(responseJSON.status === "errored"){
            PayolaSubscriptionForm.showError(form, responseJSON.error);
          }
        };

        $.ajax({
            type: 'GET',
            dataType: 'json',
            url: base_path + '/subscription_status/' + guid,
            success: handler,
            error: errorHandler
        });
    },

    showError: function(form, message) {
        $('.payola-spinner').hide();
        $(form).find(':submit')
               .prop('disabled', false)
               .trigger('error', message);
        var error_selector = form.data('payola-error-selector');
        if (error_selector) {
            $(error_selector).text(message);
            $(error_selector).show();
        } else {
            form.find('.payola-payment-error').text(message);
            form.find('.payola-payment-error').show();
        }
    },

    authenticityTokenInput: function() {
        return $('<input type="hidden" name="authenticity_token"></input>').val($('meta[name="csrf-token"]').attr("content"));
    }
};

PayolaSubscriptionForm.initialize();
