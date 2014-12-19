var PayolaCheckout = {
    initialize: function() {
        $(document).on('click', '.payola-checkout-button', function(e) {
            e.preventDefault();
            PayolaCheckout.handleCheckoutButtonClick($(this));
        });
    },

    handleCheckoutButtonClick: function(button) {
        var form = button.parent('form');
        var options = form.data();

        var handler = StripeCheckout.configure({
            key: options.publishable_key,
            image: options.product_image_path,
            token: function(token) { PayolaCheckout.tokenHandler(token, options); },
            name: options.name,
            description: options.description,
            amount: options.price,
            panelLabel: options.panel_label,
            allowRememberMe: options.allow_remember_me,
            zipCode: options.verify_zip_code,
            billingAddress: options.billing_address,
            shippingAddress: options.shipping_address,
            currency: options.currency,
            email: options.email || undefined
        });

        handler.open();
    },

    tokenHandler: function(token, options) {
        var form = $("#" + options.form_id);
        console.log(options.form_id);
        form.append($('<input type="hidden" name="stripeToken">').val(token.id));
        form.append($('<input type="hidden" name="stripeEmail">').val(token.email));
        if (options.signed_custom_fields) {
          form.append($('<input type="hidden" name="signed_custom_fields">').val(options.signed_custom_fields));
        }

        $(".payola-checkout-button").prop("disabled", true);
        $(".payola-checkout-button-text").hide();
        $(".payola-checkout-button-spinner").show();
        $.ajax({
            type: "POST",
            url: options.base_path + "/buy/" + options.product_class + "/" + options.product_permalink,
            data: form.serialize(),
            success: function(data) { PayolaCheckout.poll(data.guid, 60, options); },
            error: function(data) { PayolaCheckout.showError(data.responseJSON.error, options); }
        });
    },

    showError: function(error, options) {
        var error_div = $("#" + options.error_div_id);
        error_div.html(error);
        error_div.show();
        $(".payola-checkout-button").prop("disabled", false);
        $(".payola-checkout-button-spinner").hide();
        $(".payola-checkout-button-text").show();
    },

    poll: function(guid, num_retries_left, options) {
        if (num_retries_left === 0) {
            PayolaCheckout.showError("This seems to be taking too long. Please contact support and give them transaction ID: " + guid, options);
            return;
        }

        var handler = function(data) {
            if (data.status === "finished") {
                window.location = options.base_path + "/confirm/" + guid;
            } else if (data.status === "errored") {
                PayolaCheckout.showError(data.error, options);
            } else {
                setTimeout(function() { PayolaCheckout.poll(guid, num_retries_left - 1, options); }, 500);
            }
        };

        $.ajax({
            type: "GET",
            url: options.base_path + "/status/" + guid,
            success: handler,
            error: handler
        });
    }
};
$(function() { PayolaCheckout.initialize(); });
