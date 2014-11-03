# Payola Changelog

* v1.1.0 - 2014-11-03
  - Add customizable mailers
  - Pass currency through properly and add a `default_currency` config option
  - Use data attributes to set up the checkout button instead of a JS snippet
  - Add a polymorphic `owner` association on `Payola::Sale`.
  - Allow the price to be overridden on the Checkout form

* v1.0.8 - 2014-10-27
  - Add basic support for custom forms
  - Allow passing signed data from checkout button into the charge verifier
  - Correctly pass the price into the Checkout button, which allows the `{{amount}}` macro to work properly
  - I18n the formatted_price helper

* v1.0.7 - 2014-10-21
  - Add support for ActiveJob workers
  - Document how to set Stripe keys
  - Add a callback to fetch the publishable key
  - Unpin the Rails version to allow anything >= 4.1
  - Allow Payola to be mounted anywhere, as long as it has 'as: :payola' in the mount spec

* v1.0.6 - 2014-10-19
  - First public release
