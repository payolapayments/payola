var PayolaCheckout = {
    initialize: function() {
        $(document).off('click.payola-checkout-button').on(
            'click.payola-checkout-button', '.payola-checkout-button',
            function(e) {
                e.preventDefault();
                PayolaCheckout.handleCheckoutButtonClick($(this));
            }
        );
    },

    handleCheckoutButtonClick: function(button) {
        var form = button.parent('form');
        var options = form.data();

        if (options.stripe_customer_id) {
          // If an existing Stripe customer id is specified, don't open the Stripe Checkout - just AJAX submit the form
          PayolaCheckout.submitForm(form.attr('action'), { stripe_customer_id: options.stripe_customer_id }, options);
        } else {
          // Open a Stripe Checkout to collect the customer's billing details
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
              bitcoin: options.bitcoin,
              email: options.email || undefined
          });

          handler.open();
        }
    },

    tokenHandler: function(token, options) {
        var form = $("#" + options.form_id);
        form.append($('<input type="hidden" name="stripeToken">').val(token.id));
        form.append($('<input type="hidden" name="stripeEmail">').val(token.email));
        if (options.signed_custom_fields) {
          form.append($('<input type="hidden" name="signed_custom_fields">').val(options.signed_custom_fields));
        }

        PayolaCheckout.submitForm(form.attr('action'), form.serialize(), options);
    },

    submitForm: function(url, data, options) {
        $(".payola-checkout-button").prop("disabled", true);
        $(".payola-checkout-button-text").hide();
        $(".payola-checkout-button-spinner").show();
        $.ajax({
            type: "POST",
            url: url,
            data: data,
            success: function(data) { PayolaCheckout.poll(data.guid, 60, options); },
            error: function(data) { PayolaCheckout.showError(jQuery.parseJSON(data.responseText).error, options); }
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
            error: function(xhr){ handler(jQuery.parseJSON(xhr.responseText)) }
        });
    }
};

PayolaCheckout.initialize();
