module TradoStripeModule
    module Generators
        class ViewsGenerator < Rails::Generators::Base
            source_root File.expand_path("../../../../app/views", __FILE__)

            def copy_views
                copy_file 'carts/_stripe_credit_card_form.html.erb', "app/views/themes/#{Store.settings.theme.name}/carts/_stripe_credit_card_form.html.erb"
                copy_file 'orders/_credit_card_data.html.erb', "app/views/themes/#{Store.settings.theme.name}/orders/_credit_card_data.html.erb"
                puts "Copied to your #{Store.settings.theme.name} theme!"
            end
        end
    end
end