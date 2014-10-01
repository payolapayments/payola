# Payola

One-off and subscription payments for your Rails application.

*Note: this whole thing should be treated as alpha-level, at best. It's based on currently-running code but it hasn't had the same level of testing yet.*

## Installation

Add Payola to your Gemfile:

```ruby
gem 'payola-payments'
```

Run the installer and install the migrations:

```bash
$ rails g payola:install
$ rake db:migrate
```

### One-off Sales

To start selling one-off products, just include `Payola::Sellable`. For example, if you have a `Book` model:

```
class Book < ActiveRecord::Base
  include Payola::Sellable
end
```

Each sellable model requires two attributes:

* `permalink`, a human-readable slug that is exposed in the URL
* `name`, a human-readable name exposed on product pages

When people buy your product, Payola records information in `Payola::Sale` records, and will record history if you have the `paper_trail` gem installed. **It is highly recommended to install paper_trail**.

To sell a product, send the user to `/payola/buy/:product_class/:permalink`. For our book example, if you have a Book with the permalink `mastering-modern-payments, you would send them to:

```
/payola/buy/book/mastering-modern-payments
```

You can provide short-cut paths in your application's routes like this:

```
get '/buy/mmp', to: 'payola/transactions#new', defaults: {
  product_class: 'book',
  permalink: 'mastering-modern-payments'
}
```

### Subscriptions

TODO

## Configuration

```ruby
# config/initializers/payola.rb

Payola.configure do |payola|
  payola.subscribe 'payola.sale.finished' do |sale|
    SaleMailer.receipt(sale.guid).deliver
  end

  payola.subscribe 'payola.sale.failed' do |sale|
    SaleMailer.admin_failed(sale.guid).deliver
  end

  payola.subscribe 'payola.sale.refunded' do |sale|
    SaleMailer.admin_refunded(sale.guid).deliver
  end
end
```

### Events

Payola wraps the StripeEvent gem for event processing and adds a few special sale-related events. Each one of these events passes the related `Sale` instance instead of a `Stripe::Event`. They are sent in-process so you don't have to wait for Stripe to send the corresponding webhooks.

* `payola.sale.finished`, when a sale completes successfully
* `payola.sale.failed`, when a charge fails
* `payola.sale.refunded`, when a charge is refunded

### Webhooks

You can subscribe to any webhook events you want as well. Payola will dedupe events as they come in. Make sure to set your webhook address in Stripe's management interface to:

`https://www.example.com/payola/events`

To subscribe to a webhook event:

```ruby
Payola.configure do |payola|
  payola.subscribe 'charge.succeeded' do |event|
    sale = Sale.find_by(stripe_id: event.data.object.id)
    SaleMailer.admin_receipt(sale.guid)
  end
end

### Background Jobs

Payola will attempt to auto-detect the job queuing system you are using. It currently supports the following systems:

* Sidekiq

If you want to force Payola to use a specific supported system, just set `background_worker` to the appropriate symbol. For example:

```ruby
Payola.background_worker = :sidekiq
```

You can also set this to anything with a `call` method, for complete control over how Payola's jobs get queued. For example, you can run transactions in-process like this:

```ruby
Payola.background_worker = lambda do |sale|
  sale.process!
end
```

## License

Please see the LICENSE file for licensing details.

## Author

Pete Keen, [@zrail](https://twitter.com/zrail), [https://www.petekeen.net](https://www.petekeen.net)