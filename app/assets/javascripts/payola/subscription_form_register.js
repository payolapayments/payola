var PayolaRegistrationForm = {
    initialize: function() {
        $(document).off('submit.payola-register-form').on(
            'submit.payola-register-form', '.payola-register-form',
            function() {
                e.preventDefault();
                return PayolaRegistrationForm.handleSubmit($(this));
            }
        );
    },

    handleSubmit: function(form) {
        $(form).find(':submit').prop('disabled', true);
        $('.payola-spinner').show();
        PayolaRegistrationForm.makeCustomer(form);
        return false;
    },

    // Could be more DRY
    makeCustomer: function(form) {

        var email = form.find("[data-payola='email']").val();
        var coupon = form.find("[data-payola='coupon']").val();
        var quantity = form.find("[data-payola='quantity']").val();

        var base_path = form.data('payola-base-path');
        var plan_type = form.data('payola-plan-type');
        var plan_id = form.data('payola-plan-id');

        var action = $(form).attr('action');

        form.append($('<input type="hidden" name="[user]plan_id">').val(plan_id));
        form.append($('<input type="hidden" name="plan_type">').val(plan_type));
        form.append($('<input type="hidden" name="plan_id">').val(plan_id));
        form.append($('<input type="hidden" name="stripeEmail">').val(email));
        form.append($('<input type="hidden" name="coupon">').val(coupon));
        form.append($('<input type="hidden" name="quantity">').val(quantity));
        form.append(PayolaRegistrationForm.authenticityTokenInput());

        $.ajax({
            type: "POST",
            url: action,
            data: form.serialize(),
            success: function(data) { PayolaRegistrationForm.poll(form, 60, data.guid, base_path); },
            error: function(data) { PayolaRegistrationForm.showError(form, jQuery.parseJSON(data.responseText).error); }
        });
    },

    poll: function(form, num_retries_left, guid, base_path) {
        if (num_retries_left === 0) {
            PayolaRegistrationForm.showError(form, "This seems to be taking too long. Please contact support and give them transaction ID: " + guid);
        }
        var handler = function(data) {
            if (data.status === "active") {
                form.append($('<input type="hidden" name="payola_subscription_guid"></input>').val(guid));
                form.append(PayolaRegistrationForm.authenticityTokenInput());
                form.get(0).submit();
            } else {
                setTimeout(function() { PayolaRegistrationForm.poll(form, num_retries_left - 1, guid, base_path); }, 500);
            }
        };
        var errorHandler = function(jqXHR){
          var responseJSON = jQuery.parseJSON(jqXHR.responseText);
          if(responseJSON.status === "errored"){
            PayolaRegistrationForm.showError(form, responseJSON.error);
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
        $(form).find(':submit').prop('disabled', false);
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

PayolaRegistrationForm.initialize();
