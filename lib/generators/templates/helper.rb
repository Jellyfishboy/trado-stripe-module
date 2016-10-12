module StripeHelper

    def stripe_form_tag f
        raw("<div class='paypal-form-wrapper'>#{f.radio_button(:payment_type, 'paypal', checked: true)}#{image_tag('paypal-icon.png')}</div>")
    end
end