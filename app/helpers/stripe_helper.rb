module StripeHelper

    def stripe_checkout_fields f
        render 'carts/checkout_fields', format: [:html], f: f
    end

    def stripe_credit_card_data order
        render 'orders/credit_card_data', format: [:html], order: order
    end

    def stripe_application_layout 
        render 'layout/meta_tags', format: [:html]
    end

    def stripe_store_setting_fields f
        render 'admin/store_setting_fields', format: [:html], f: f
    end
end