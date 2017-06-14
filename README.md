# Payola

[![Gem Version](https://badge.fury.io/rb/payola-payments.svg)](http://badge.fury.io/rb/payola-payments) [![CircleCI](https://circleci.com/gh/payolapayments/payola.svg?style=shield)](https://circleci.com/gh/payolapayments/payola) [![Code Climate](https://codeclimate.com/github/payolapayments/payola/badges/gpa.svg)](https://codeclimate.com/github/payolapayments/payola) [![Test Coverage](https://codeclimate.com/github/payolapayments/payola/badges/coverage.svg)](https://codeclimate.com/github/payolapayments/payola) [![Dependency Status](https://gemnasium.com/badges/github.com/payolapayments/payola.svg)](https://gemnasium.com/github.com/payolapayments/payola)


Payments with Stripe for your Rails application.

## What does this do?

Payola is a drop-in Rails engine that lets you sell one or more products by just including a module in your models. It includes:

* An easy to embed, easy to customize, async Stripe Checkout button
* Asynchronous payments, usable with any background processing system
* Full webhook integration
* Easy extension hooks for adding your own functionality
* Customizable emails

To see Payola in action, check out the site for [Mastering Modern Payments: Using Stripe with Rails](https://www.masteringmodernpayments.com). Read the book to find out the whys behind Payola's design.

## Installation

Add Payola to your Gemfile:

```ruby
gem 'payola-payments'
```

Run the installer:

```bash
$ rails g payola:install
$ rake db:migrate
```

(**Note**: do not run `rake payola:install:migrations`. Payola's migrations live inside the gem and do not get copied into your application.)

Optionally, tell Stripe about your application. Add this as a webhook in your [Stripe dashboard](https://dashboard.stripe.com/account/webhooks):

```
https://your.website.example.com/payola/events
```

## Additional Setup Resources


[One-time payments](https://github.com/payolapayments/payola/wiki/One-time-payments)

[Configuration options](https://github.com/payolapayments/payola/wiki/Configuration-options)

[Subscriptions](https://github.com/payolapayments/payola/wiki/Subscriptions)

## TODO

* Multiple subscriptions per customer
* Affiliate tracking
* Easy metered billing

## License

Please see the LICENSE file for licensing details.

## Sponsorship

You can sponsor Payola development on [Patreon](https://www.patreon.com/user?u=5541136).

## Changelog

Please see [CHANGELOG.md](CHANGELOG.md).

## Contributing

1. Fork the project
2. Make your changes, including tests that exercise the code
3. Summarize your changes in [CHANGELOG.md](CHANGELOG.md)
4. Make a pull request

Version announcements happen on the [Payola Payments Google group](https://groups.google.com/forum/#!forum/payola-payments) and [@payolapayments](https://twitter.com/payolapayments).

## Author

Pete Keen, [@zrail](https://twitter.com/zrail), [https://www.petekeen.net](https://www.petekeen.net)
