var PayolaOnestepSubscriptionForm = {
    initialize: function() {
        $(document).on('submit', '.payola-onestep-subscription-form', function() {
            return PayolaOnestepSubscriptionForm.handleSubmit($(this));
        });
    },

    handleSubmit: function(form) {
        $(':submit').prop('disabled', true);
        $('.payola-spinner').show();
        Stripe.card.createToken(form, function(status, response) {
            PayolaOnestepSubscriptionForm.stripeResponseHandler(form, status, response);
        });
        return false;
    },

    stripeResponseHandler: function(form, status, response) {
        if (response.error) {
            PayolaOnestepSubscriptionForm.showError(form, response.error.message);
        } else {
            var email = form.find("[data-payola='email']").val();
            var coupon = form.find("[data-payola='coupon']").val();
            var quantity = form.find("[data-payola='quantity']").val();

            var base_path = form.data('payola-base-path');
            var plan_type = form.data('payola-plan-type');
            var plan_id = form.data('payola-plan-id');

            var action = $(form).attr('action');

            form.append($('<input type="hidden" name="plan_type">').val(plan_type));
            form.append($('<input type="hidden" name="plan_id">').val(plan_id));
            form.append($('<input type="hidden" name="stripeToken">').val(response.id));
            form.append($('<input type="hidden" name="stripeEmail">').val(email));
            form.append($('<input type="hidden" name="coupon">').val(coupon));
            form.append($('<input type="hidden" name="quantity">').val(quantity));
            form.append(PayolaOnestepSubscriptionForm.authenticityTokenInput());
            $.ajax({
                type: "POST",
                url: action,
                data: form.serialize(),
                success: function(data) { PayolaOnestepSubscriptionForm.poll(form, 60, data.guid, base_path); },
                error: function(data) { PayolaOnestepSubscriptionForm.showError(form, data.responseJSON.error); }
            });
        }
    },

    poll: function(form, num_retries_left, guid, base_path) {
        if (num_retries_left === 0) {
            PayolaOnestepSubscriptionForm.showError(form, "This seems to be taking too long. Please contact support and give them transaction ID: " + guid);
        }
        var handler = function(data) {
            if (data.status === "active") {
                window.location = base_path + '/confirm_subscription/' + guid;
            } else {
                setTimeout(function() { PayolaOnestepSubscriptionForm.poll(form, num_retries_left - 1, guid, base_path); }, 500);
            }
        };
        var errorHandler = function(jqXHR){
            PayolaOnestepSubscriptionForm.showError(form, jqXHR.responseJSON.error);
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
        $(':submit').prop('disabled', false);
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

$(function() { PayolaOnestepSubscriptionForm.initialize() } );
