module TradoStripeModule
	module Generators
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path("../../templates", __FILE__)

			def copy_migration
				unless stripe_migration_already_exists?
					timestamp_number = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
					copy_file "migration.rb", "db/migrate/#{timestamp_number}_add_stripe_attributes.rb"
				end
			end

			def copy_controller
				template "controller.rb", "app/controllers/carts/stripe_controller.rb"
			end

			def assign_model_concerns
				order_content = <<-CONTENT

	has_order_stripe
				CONTENT
				transaction_content = <<-CONTENT

	has_transaction_stripe
				CONTENT

				store_setting_content = <<-CONTENT

	has_store_setting_stripe
				CONTENT

				inject_into_file "app/models/order.rb", order_content, after: "class Order < ActiveRecord::Base"
				inject_into_file "app/models/transaction.rb", transaction_content, after: "class Transaction < ActiveRecord::Base"
				inject_into_file "app/models/store_setting.rb", store_setting_content, after: "class StoreSetting < ActiveRecord::Base"
			end

			private

			def stripe_migration_already_exists?
				Dir.glob("#{File.join(destination_root, File.join("db", "migrate"))}/[0-9]*_*.rb").grep(/\d+_add_stripe_attributes.rb$/).first
			end
		end
	end
end