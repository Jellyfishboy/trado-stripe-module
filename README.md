![alt text](http://cdn0.trado.io/trado-promo/assets/img/cropped.png "Trado")

# Stripe Module
Module for Stripe payment functionality in the Trado Ecommerce platform. If you would like to get started using the Trado Ecommerce platform, head on over to the [Official site](http://www.trado.io/?utm_source=github&utm_medium=website&utm_campaign=trado)!

[Release notes](http://release.tomdallimore.com/projects/trado-stripe)

## Installation

Add module to your Gemfile:

```ruby
gem 'trado_stripe_module'
```

Then run bundle to install the Gem:

```sh
bundle install
```

Set up an initializer file with your Stripe API keys:
*(You can sign up for a Stripe account [here](https://developer.paypal.com))*

```ruby
Rails.application.config.stripe.secret_key = "stripe_secret_key"
Rails.application.config.stripe.publishable_key = "stripe_public_key"
```
e.g. *config/initializers/stripe.rb*. It would be a good idea to store sensitive data in *config/secrets.yml*.


Now generate migrations, copy controllers and assign model concerns:

```sh
rails generate trado_stripe_module:install
bundle exec rake db:migrate
```

Add the Stripe JS files to the theme application.js:

```js
//= require trado-stripe
```

You can also customise the HTML for your credit card form and data in checkout:

```sh
rails generate trado_stripe_module:views
```

Restart the main application server:

```sh
foreman start -f Procfile.dev
```


You can then modify the **Stripe Statement Descriptor** in store settings to customise your customers credit card statement information.

## Versioning

Trado Stripe module follows Semantic Versioning 2.0 as defined at
<http://semver.org>.

## How to contribute

* Fork the project
* Create your feature or bug fix
* Add the requried tests for it.
* Commit (do not change version or history)
* Send a pull request against the *development* branch

## Copyright
Copyright (c) 2016 [Tom Dallimore](http://www.tomdallimore.com/?utm_source=trado-paypal-module-github&utm_medium=website&utm_campaign=tomdallimore) ([@tom_dallimore](http://twitter.com/tom_dallimore))  
Licenced under the MIT licence.

