var PayolaOnestepSubscriptionForm = {
    initialize: function() {
        $(document).off('submit.payola-onestep-subscription-form').on(
            'submit.payola-onestep-subscription-form', '.payola-onestep-subscription-form',
            function() {
                return PayolaOnestepSubscriptionForm.handleSubmit($(this));
            }
        );
    },

    handleSubmit: function(form) {
        if (!PayolaOnestepSubscriptionForm.validateForm(form)) {
            return false;
        }

        $(form).find(':submit').prop('disabled', true);
        $('.payola-spinner').show();
        Stripe.card.createToken(form, function(status, response) {
            PayolaOnestepSubscriptionForm.stripeResponseHandler(form, status, response);
        });
        return false;
    },

    validateForm: function(form) {
        var cardNumber = $( "input[data-stripe='number']" ).val();
        if (!Stripe.card.validateCardNumber(cardNumber)) {
            PayolaOnestepSubscriptionForm.showError(form, 'The card number is not a valid credit card number.');
            return false;
        }
        if ($("[data-stripe='exp']").length){
            var valid = !Stripe.card.validateExpiry($("[data-stripe='exp']").val());
        }else{
            var expMonth = $("[data-stripe='exp_month']").val();
            var expYear = $("[data-stripe='exp_year']").val();
            var valid = !Stripe.card.validateExpiry(expMonth, expYear);
        }
        if (valid) {
            PayolaOnestepSubscriptionForm.showError(form, "Your card's expiration month/year is invalid.");
            return false;
        }

        var cvc = $( "input[data-stripe='cvc']" ).val();
        if(!Stripe.card.validateCVC(cvc)) {
            PayolaOnestepSubscriptionForm.showError(form, "Your card's security code is invalid.");
            return false;
        }

        return true;
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
                error: function(data) { PayolaOnestepSubscriptionForm.showError(form, jQuery.parseJSON(data.responseText).error); }
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
            PayolaOnestepSubscriptionForm.showError(form, jQuery.parseJSON(jqXHR.responseText).error);
        };
        
        if (typeof guid != 'undefined') {
            $.ajax({
                type: 'GET',
                dataType: 'json',
                url: base_path + '/subscription_status/' + guid,
                success: handler,
                error: errorHandler
            });
        }
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

PayolaOnestepSubscriptionForm.initialize();
