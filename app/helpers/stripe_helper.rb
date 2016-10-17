module StripeHelper

    def stripe_checkout_fields f
        render "themes/#{Store.settings.theme.name}/carts/stripe_credit_card_form", format: [:html], f: f
    rescue ActionView::MissingTemplate
        render 'carts/stripe_credit_card_form', format: [:html], f: f
    end

    def stripe_credit_card_data order
        render "themes/#{Store.settings.theme.name}/orders/credit_card_data", format: [:html], order: order
    rescue ActionView::MissingTemplate
        render 'carts/credit_card_data', format: [:html], f: f
    end

    def stripe_application_layout 
        render 'layout/meta_tags', format: [:html]
    end

    def stripe_store_setting_fields f
        render 'admin/store_setting_fields', format: [:html], f: f
    end
end