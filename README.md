# Payola

[![Gem Version](https://badge.fury.io/rb/payola-payments.svg)](http://badge.fury.io/rb/payola-payments) [![CircleCI](https://circleci.com/gh/peterkeen/payola.svg?style=shield)](https://circleci.com/gh/peterkeen/payola) [![Code Climate](https://codeclimate.com/github/peterkeen/payola/badges/gpa.svg)](https://codeclimate.com/github/peterkeen/payola) [![Test Coverage](https://codeclimate.com/github/peterkeen/payola/badges/coverage.svg)](https://codeclimate.com/github/peterkeen/payola) [![Dependency Status](https://gemnasium.com/peterkeen/payola.svg)](https://gemnasium.com/peterkeen/payola)

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

Run the installer and install the migrations:

```bash
$ rails g payola:install
$ rake db:migrate
```

## Additional Setup Resources


[One-time payments](https://github.com/peterkeen/payola/wiki/One-time-payments)

[Configuration options](https://github.com/peterkeen/payola/wiki/Configuration)

[Subscriptions](https://github.com/peterkeen/payola/wiki/Subscriptions)


## Upgrade to Pro

I also sell **Payola Pro**, a collection of add-ons to Payola that enables things like drop-in Mailchimp and Mixpanel integration, as well as Stripe Connect support. It also comes with priority support and a lawyer-friendly commercial license. You can see all of the details on the [Payola Pro homepage](https://www.payola.io/pro).

## TODO

* Multiple subscriptions per customer
* Affiliate tracking
* Easy metered billing

## License

Please see the LICENSE file for licensing details.

## Contributing

1. Fork the project
2. Make your changes, including tests that exercise the code
3. Make a pull request

Version announcements happen on the [Payola Payments Google group](https://groups.google.com/forum/#!forum/payola-payments) and [@payolapayments](https://twitter.com/payolapayments).

## Author

Pete Keen, [@zrail](https://twitter.com/zrail), [https://www.petekeen.net](https://www.petekeen.net)

