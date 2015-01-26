# Payola Changelog

* v1.2.6 - 2015-01-26
  - Fix Javascript error handling for subscriptions

* v1.2.5 - 2015-01-25
  - Capure all attributes from Stripe when starting a subscription
  - Allow for use of Checkout for Subscriptions
  - Only re-use active or canceled subscriptions
  - Make plan creation idempotent

* v1.2.4 - 2015-01-06
  - Fix regressions in v1.2.3

* v1.2.3 - 2015-01-03
  - Add support for Rails 4.2
  - Re-use customers and create invoice items for setup fees
  - Add an active flag on `Payola::Coupon`
  - Fix load-order problems
  - Add support for subscription quantities
  - Properly handle form errors

* v1.2.2 - 2014-11-29
  - Optionally invert subscription controller flow
  - Fix the CSRF token behavior

* v1.2.1 - 2014-11-20
  - Make guid generator overrideable
  - Bumped minimum version of AASM to 4.0
  - Fixed a bug with the auto emails not working for webhook events
  - Code cleanup
  - Test coverage improvements

* v1.2.0 - 2014-11-17
  - Subscriptions

* v1.1.4 - 2014-11-07
  - Pass the created customer to `additional_charge_attributes`
  - Add Payola Pro license

* v1.1.3 - 2014-11-07
  - Add options for requesting billing and shipping addresses via Checkout
  - Add a callable to add additional attributes to a Stripe::Charge
  - Only talk about PDFs if PDFs are enabled

* v1.1.2 - 2014-11-06
  - Default the `From` address on receipt emails to `Payola.support_email`

* v1.1.1 - 2014-11-03
  - ActiveJob can't serialize a class or a symbol so we have to `to_s` them

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
<
