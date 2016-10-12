module StripeHelper

    def stripe_checkout_fields f
        render 'carts/checkout_fields', format: [:html], f: f
    end

    def stripe_order_confirm_data order
        render 'orders/confirm_data', format: [:html], order: order
    end

    def stripe_application_layout 
        render 'layout/_meta_tags', format: [:html]
    end

    def stripe_store_setting_fields f
        render 'admin/store_setting_fields', format: [:html]
    end
end