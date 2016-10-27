var order;

jQuery(function() {
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
  order.setupForm();
});

order = {
  setupForm: function() {
    $('.process_order').submit(function() {
      var $form = $(this);
      $('input[type=submit]').attr('disabled', true);
      $('.stripe-error, .alert-stripe-checkout, .stripe-error-terms').remove();
      $('#stripe_card_error').html('');
      $('.field_with_errors').each(function()
      {
        $(this).find('input').unwrap();
        $(this).find('select').unwrap();
      });
      if ($('#stripe_card_number').length) {
        order.validateForm($form);
        return false;
      } else {
        return true;
      }
    });
  },
  processCard: function() {
    var card;
    card = {
      number: $('#stripe_card_number').val(),
      cvc: $('#stripe_card_code').val(),
      expMonth: $('#stripe_card_month').val(),
      expYear: $('#stripe_card_year').val()
    };
    Stripe.createToken(card, order.handleStripeResponse);
  },
  handleStripeResponse: function(status, response) {
    if (status === 200) {
      $('#order_stripe_card_token').val(response.id);
      $('.process_order')[0].submit();
    } else {
      $('#stripe_card_error').text(response.error.message);
      $('#stripe-form-fields input, #stripe-form-fields select').each(function()
      {
        $(this).wrap('<div class="field_with_errors"></div>');
      });
      stripeCheckoutErrors();
      $('input[type=submit]').attr('disabled', false);
      $('#checkoutLoadingModal').modal('hide');
    }
  },
  validateForm: function(form)
  {
    $.ajax(
    {
      url: '/carts/stripe/confirm',
      type: 'POST',
      data: form.serialize(),
      dataType: 'json',
      success: function (data)
      {
        order.processCard();
      },
      error: function(xhr, evt, status)
      {
        order.jsonErrors(xhr, evt, status, form);
      }
    });
  },
  jsonErrors: function(xhr, evt, status, form)
  {
    var content, value, _i, _len, _ref, $this;
    $this = form;
    errorKeys = $.parseJSON(xhr.responseText).errors;
    $('input[type=submit]').attr('disabled', false);
    $('#checkoutLoadingModal').modal('hide');

    $.each(errorKeys, function(index, value)
    {
      var $input = $('#' + value);
      if (value === 'terms')
      {
        stripeTermsValidationMessage();
      }
      $input.wrap('<div class="field_with_errors"></div>')
    });
    stripeCheckoutErrors();
  }
};