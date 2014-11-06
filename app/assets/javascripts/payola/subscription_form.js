var PayolaSubscriptionForm = {
    initialize: function() {
        $(document).on('submit', '.payola-subscription-form', function() {
            return PayolaSubscriptionForm.handleSubmit($(this));
        });
    },

    handleSubmit: function(form) {
        form.find(':submit').prop('disabled', true);
        $('.payola-spinner').show();
        Stripe.card.createToken(form, function(status, response) {
            PayolaSubscriptionForm.stripeResponseHandler(form, status, response);
        });
        return false;
    },

    stripeResponseHandler: function(form, status, response) {
        if (response.error) {
            PayolaSubscriptionForm.showError(form, response.error.message);
            form.find(':submit').prop('disabled', false);
        } else {
            var email = form.find("[data-payola='email']").val();

            var base_path = form.data('payola-base-path');
            var plan_type = form.data('payola-plan-type');
            var plan_id = form.data('payola-plan-id');

            var data_form = $('<form></form>');
            data_form.append($('<input type="hidden" name="stripeToken">').val(response.id));
            data_form.append($('<input type="hidden" name="stripeEmail">').val(email));
            data_form.append(form.find('input[name="authenticity_token"]'));
            
            $.ajax({
                type: "POST",
                url: base_path + "/subscribe/" + plan_type + "/" + plan_id,
                data: data_form.serialize(),
                success: function(data) { PayolaSubscriptionForm.poll(form, 60, data.guid, base_path) },
                error: function(data) { PayolaSubscriptionForm.showError(form, data.responseJSON.error) }
            });
        }
    },

    poll: function(form, num_retries_left, guid, base_path) {
        if (num_retries_left == 0) {
            PayolaSubscriptionForm.showError(form, "This seems to be taking too long. Please contact support and give them transaction ID: " + guid)
        }
        $.get(base_path + '/status/' + guid, function(data) {
            if (data.status === "finished") {
                form.append($('<input type="hidden" name="payola_sale_guid"></input>').val(guid));
                form.get(0).submit();
            } else if (data.status === "errored") {
                PayolaSubscriptionForm.showError(form, data.error);
            } else {
                setTimeout(function() { PayolaSubscriptionForm.poll(form, num_retries_left - 1, guid, base_path) }, 500);
            }
        });
    },

    showError: function(form, message) {
        $('.payola-spinner').hide();
        var error_selector = form.data('payola-error-selector');
        if (error_selector) {
            $(error_selector).text(message);
        } else {
            form.find('.payola-payment-error').text(message);
        }
    }
};

$(function() { PayolaSubscriptionForm.initialize() } );
