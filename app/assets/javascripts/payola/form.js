var PayolaPaymentForm = {
    initialize: function() {
        $(document).on('submit', '.payola-payment-form', function() {
            return PayolaPaymentForm.handleSubmit($(this));
        });
    },

    handleSubmit: function(form) {
        form.find(':submit').prop('disabled', true);
        $('.payola-spinner').show();
        Stripe.card.createToken(form, function(status, response) {
            PayolaPaymentForm.stripeResponseHandler(form, status, response);
        });
        return false;
    },

    stripeResponseHandler: function(form, status, response) {
        if (response.error) {
            PayolaPaymentForm.showError(form, response.error.message);
            form.find(':submit').prop('disabled', false);
        } else {
            var email = form.find("[data-payola='email']").val();

            var base_path = form.data('payola-base-path');
            var product = form.data('payola-product');
            var permalink = form.data('payola-permalink');

            var data_form = $('<form></form>');
            data_form.append($('<input type="hidden" name="stripeToken">').val(response.id));
            data_form.append($('<input type="hidden" name="stripeEmail">').val(email));
            data_form.append(form.find('input[name="authenticity_token"]'));
            
            $.ajax({
                type: "POST",
                url: base_path + "/buy/" + product + "/" + permalink,
                data: data_form.serialize(),
                success: function(data) { PayolaPaymentForm.poll(form, 60, data.guid, base_path) },
                error: function(data) { PayolaPaymentForm.showError(form, data.responseJSON.error) }
            });
        }
    },

    poll: function(form, num_retries_left, guid, base_path) {
        if (num_retries_left == 0) {
            PayolaPaymentForm.showError(form, "This seems to be taking too long. Please contact support and give them transaction ID: " + guid)
        }
        $.get(base_path + '/status/' + guid, function(data) {
            if (data.status === "finished") {
                form.append($('<input type="hidden" name="payola_sale_guid"></input>').val(guid));
                form.get(0).submit();
            } else if (data.status === "errored") {
                PayolaPaymentForm.showError(form, data.error);
            } else {
                setTimeout(function() { PayolaPaymentForm.poll(form, num_retries_left - 1, guid, base_path) }, 500);
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

$(function() { PayolaPaymentForm.initialize() } );
