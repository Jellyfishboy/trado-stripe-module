require_dependency 'lib/payatron_4000'

module TradoStripeModule

    class Striper

        # Creates a charge for the Stripe API; receives a response and in turn creates the relevant transaction records,
        # sends a confirmation email and redirects the user.
        #
        # @param order [Object]
        # @param session [Object
        def self.complete order, session, ip_address
            order.transfer(order.cart)
            charge = Stripe::Charge.create(
                amount: Store::Price.new(price: order.gross_amount, tax_type: 'net').singularize,
                currency: Store.settings.currency_code,
                customer: order.stripe_customer_id,
                description: "Order ID ##{order.id} | #{order.billing_address.full_name} | #{order.email}",
                metadata: Hash[ *order.order_items.collect { |item| [ "order_item_#{item.id}", "#{item.product.name} - #{item.sku.full_sku}" ] }.flatten ],
                statement_descriptor: Store.settings.stripe_statement_descriptor
            )
            if charge.paid
                TradoStripeModule::Striper.successful(charge, order)
                TradoStripeModule::Striper.assign_card_data(order)
                Payatron4000.destroy_cart(session)
                Payatron4000.decommission_order(order)
                order.reload
                Mailatron4000::Orders.confirmation_email(order)
                return Rails.application.routes.url_helpers.success_order_url(order, host: Trado::Application.config.action_mailer.default_url_options[:host])
            end
        rescue Stripe::CardError => e
            body = e.json_body
            err  = body[:error]
            TradoStripeModule::Striper.failed(err, order)
            order.reload
            Mailatron4000::Orders.confirmation_email(order)
            return Rails.application.routes.url_helpers.failed_order_url(order, host: Trado::Application.config.action_mailer.default_url_options[:host])
        end

        # Upon successfully completing an order with a Stripe payment option a new transaction record is created, stock is updated for the relevant SKU
        #
        # @param charge [Object]
        # @param order [Object]
        def self.successful charge, order
            Transaction.new(  :fee                      => charge.application_fee,  
                              :order_id                 => order.id, 
                              :payment_status           => 'completed', 
                              :transaction_type         => 'Credit', 
                              :tax_amount               => order.tax_amount, 
                              :stripe_charge_id         => charge.id, 
                              :payment_type             => 'stripe',
                              :net_amount               => order.net_amount,
                              :gross_amount             => order.gross_amount
            ).save(validate: false)
            Payatron4000.update_stock(order)
            Payatron4000.increment_product_order_count(order.products)
        end

        
        # When an order has failed to complete, a new transaction record is created with a logged status reason
        #
        # @param error [Object]
        # @param order [Object]
        def self.failed error, order
            Transaction.new(  :fee                        => 0, 
                              :gross_amount               => order.gross_amount, 
                              :order_id                   => order.id, 
                              :payment_status             => 'failed', 
                              :transaction_type           => 'Credit', 
                              :tax_amount                 => order.tax_amount, 
                              :stripe_charge_id           => nil, 
                              :payment_type               => 'stripe',
                              :net_amount                 => order.net_amount,
                              :status_reason              => error[:message],
                              :error_code                 => error[:code].to_i
            ).save(validate: false)
            Payatron4000.increment_product_order_count(order.products)
        end

        # Assign the card data used for the order
        #
        # @param order [Object]
        def self.assign_card_data order
          default_card = order.default_card
          order.update(
            stripe_card_last4: default_card.last4,
            stripe_card_brand: default_card.brand,
            stripe_card_expiry_date: "#{default_card.exp_month}/#{default_card.exp_year}"
          )
        end
    end
end