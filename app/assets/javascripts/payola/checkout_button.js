var PayolaCheckout = {
    setUpStripeCheckoutButton: function(options) {
        var handler = StripeCheckout.configure({
            key: options.publishable_key,
            image: options.product_image_path,
            token: function(token) { PayolaCheckout.tokenHandler(token, options) }
        });

        document.getElementById(options.button_id).addEventListener('click', function(e) {
            handler.open({
                name: options.name,
                description: options.description,
                amount: options.price,
                panelLabel: options.panel_label,
                allowRememberMe: options.allow_remember_me,
                zipCode: options.verify_zip_code,
                currency: options.currency,
                email: options.email || undefined
            });
            e.preventDefault();
        });
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
            success: function(data) { PayolaCheckout.poll(data.guid, 60, options) },
            error: function(data) { PayolaCheckout.showError(data.responseJSON.error, options) }
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
        if (num_retries_left == 0) {
            PayolaCheckout.showError("This seems to be taking too long. Please contact support and give them transaction ID: " + guid, options);
            return;
        }

        $.get(options.base_path + "/status/" + guid, function(data) {
            if (data.status === "finished") {
                window.location = options.base_path + "/confirm/" + guid;
            } else if (data.status === "errored") {
                PayolaCheckout.showError(data.error, options);
            } else {
                setTimeout(function() { PayolaCheckout.poll(guid, num_retries_left - 1, options) }, 500);
            }
        });
    }
}
