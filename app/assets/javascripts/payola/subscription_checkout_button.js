var PayolaSubscriptionCheckout = {
    initialize: function() {
        $(document).on('click', '.payola-subscription-checkout-button', function(e) {
            e.preventDefault();
            PayolaSubscriptionCheckout.handleCheckoutButtonClick($(this));
        });
    },

    handleCheckoutButtonClick: function(button) {
        var form = button.parent('form');
        var options = form.data();

        var handler = StripeCheckout.configure({
            key: options.publishable_key,
            image: options.plan_image_path,
            token: function(token) { PayolaSubscriptionCheckout.tokenHandler(token, options); },
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
        form.append($('<input type="hidden" name="quantity">').val(options.quantity));
        if (options.signed_custom_fields) {
          form.append($('<input type="hidden" name="signed_custom_fields">').val(options.signed_custom_fields));
        }

        $(".payola-subscription-checkout-button").prop("disabled", true);
        $(".payola-subscription-checkout-button-text").hide();
        $(".payola-subscription-checkout-button-spinner").show();
        $.ajax({
            type: "POST",
            url: options.base_path + "/subscribe/" + options.plan_class + "/" + options.plan_id,
            data: form.serialize(),
            success: function(data) { PayolaSubscriptionCheckout.poll(data.guid, 60, options); },
            error: function(data) { PayolaSubscriptionCheckout.showError(data.responseJSON.error, options); }
        });
    },

    showError: function(error, options) {
        var error_div = $("#" + options.error_div_id);
        error_div.html(error);
        error_div.show();
        $(".payola-subscription-checkout-button").prop("disabled", false);
        $(".payola-subscription-checkout-button-spinner").hide();
        $(".payola-subscription-checkout-button-text").show();
    },

    poll: function(guid, num_retries_left, options) {
        if (num_retries_left === 0) {
            PayolaSubscriptionCheckout.showError("This seems to be taking too long. Please contact support and give them transaction ID: " + guid, options);
            return;
        }

        var handler = function(data) {
            if (data.status === "active") {
                window.location = options.base_path + "/confirm_subscription/" + guid;
            } else if (data.status === "errored") {
                PayolaSubscriptionCheckout.showError(data.error, options);
            } else {
                setTimeout(function() { PayolaSubscriptionCheckout.poll(guid, num_retries_left - 1, options); }, 500);
            }
        };

        $.ajax({
            type: "GET",
            url: options.base_path + "/subscription_status/" + guid,
            success: handler,
            error: handler
        });
    }
};
$(function() { PayolaSubscriptionCheckout.initialize(); });
