module TradoStripeModule
    module ActiveRecord
        extend ActiveSupport::Concern

        module ClassMethods
            def has_order_stripe
                attr_accessible :stripe_customer_id, :stripe_card_token, :stripe_card_last4, :stripe_card_brand, :stripe_card_expiry_date
                attr_accessor :stripe_card_token

                after_commit :create_stripe_customer,                           on: :create, if: :no_stripe_customer_id?
                after_commit :update_stripe_customer,                           on: :update, if: :email_or_billing_name_changed?

                define_method("stripe_customer") do
                    begin
                        @customer ||= Stripe::Customer.retrieve(stripe_customer_id)
                    rescue Stripe::InvalidRequestError
                        create_stripe_customer
                    end
                end

                define_method("stripe_cards") do
                    stripe_customer.sources.all(:object => "card")['data']
                end

                define_method("default_card") do
                    stripe_customer.sources.retrieve(stripe_customer.default_source)
                end

                define_method("create_stripe_card") do
                    card = stripe_customer.sources.create(source: stripe_card_token)
                    self.update(
                        stripe_card_last4: card.last4,
                        stripe_card_brand: card.brand,
                        stripe_card_expiry_date: "#{card.exp_month}/#{card.exp_year}"
                    )
                end

                define_method("remove_redundant_stripe_cards") do
                    stripe_cards.each do |card|
                        stripe_customer.sources.retrieve(card.id).delete()
                    end
                end

                define_method("create_stripe_customer") do
                    customer = Stripe::Customer.create(
                        email: email,
                        description: billing_address.full_name
                    )
                    self.update_column(:stripe_customer_id, customer.id)
                end

                define_method("update_stripe_customer") do
                    customer = stripe_customer
                    customer.email = email
                    customer.description = billing_address.full_name
                    customer.save
                end

                define_method("no_stripe_customer_id?") do
                    stripe_customer_id.present? ? false : true
                end

                define_method("email_or_billing_name_changed?") do
                    email_changed? || billing_address.first_name_changed? || billing_address.last_name_changed?
                end
            end

            def has_transaction_stripe
                attr_accessible :stripe_charge_id
            end

            def has_store_setting_stripe
                attr_accessible :stripe_statement_descriptor

                validates :stripe_statement_descriptor,                     length: { maximum: 22, message: :too_long }, format: { with: /\A[A-Za-z0-9 _]*[A-Za-z0-9][A-Za-z0-9 _]*\z/}
            end
        end
    end
end