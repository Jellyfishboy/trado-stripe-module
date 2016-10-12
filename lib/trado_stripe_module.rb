module TradoStripeModule
end

require 'stripe'
require 'stripe-rails'

require 'trado_stripe_module/engine'
require 'trado_stripe_module/version'
require 'trado_stripe_module/active_record'
require 'trado_stripe_module/striper'

ActiveRecord::Base.send(:include, TradoStripeModule::ActiveRecord)
