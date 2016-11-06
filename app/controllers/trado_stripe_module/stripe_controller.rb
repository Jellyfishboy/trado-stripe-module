class TradoStripeModule::StripeController < ApplicationController
    skip_before_action :authenticate_user!
    include CartBuilder

    def confirm
        set_order
        set_cart_totals
        set_grouped_countries
        set_browser_data
        @order.attributes = params[:order]
        respond_to do |format|
            format.html do
                begin
                    if @order.save
                        set_order_id_session
                        @order.calculate(current_cart, Store.tax_rate)
                        @order.remove_redundant_stripe_cards
                        @order.create_stripe_card
                        redirect_to confirm_order_url(@order)
                    else
                        flash_message :error, 'An error ocurred with your order. Please try again.'
                        render theme_presenter.page_template_path('carts/checkout'), layout: theme_presenter.layout_template_path
                    end
                rescue Stripe::InvalidRequestError, Stripe::APIConnectionError, Stripe::CardError, NoMethodError => e
                    flash_message :error, 'An error ocurred with your order, please confirm your card details and try again.'  
                    Rails.logger.error "Stripe Error: #{e} ? #{@order.email} | #{@order.id}"
                    render theme_presenter.page_template_path('carts/checkout'), layout: theme_presenter.layout_template_path
                end
            end

            format.json do
                if @order.valid?
                    render json: { }, status: 200
                else
                    render json: { errors: @order.errors.keys.map{|e| e.to_s.split('.').join('_') } }, status: 422
                end
            end
        end
    end
end