class AddStripeAttributes < ActiveRecord::Migration
    def self.up
        add_column :orders, :stripe_customer_id, :string
        add_column :orders, :stripe_card_last4, :string
        add_column :orders, :stripe_card_brand, :string
        add_column :orders, :stripe_expiry_date, :string
        add_column :transactions, :stripe_charge_id, :string
        add_column :store_settings, :stripe_statement_descriptor, :string
    end

    def self.down
        remove_column :orders, :stripe_customer_id, :string
        remove_column :orders, :stripe_card_last4, :string
        remove_column :orders, :stripe_card_brand, :string
        remove_column :orders, :stripe_expiry_date, :string
        remove_column :transactions, :stripe_charge_id, :string
        remove_column :store_settings, :stripe_statement_descriptor, :string
    end
end
