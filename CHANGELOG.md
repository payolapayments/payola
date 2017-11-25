# Payola Changelog

Payola adheres to [Semantic Versioning](http://semver.org/).

All notable changes to Payola will be documented in this file.

## v1.5.1 - 2017-11-25
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.5.0...v1.5.1)

### Enhancements
- Support Turbolinks & non-Turbolinks apps reliably. #254
- Added support to `ChangeSubscriptionPlan` for `trial_end` and `coupon`
- Reset subscription `cancel_at_period_end` in `ChangeSubscriptionPlan`
- Remove `spec/` and `.gitignored` files from `gemspec.files`. #293
- Allow checkout form to override currency. #296
- Add support for single exp field
- Support Rails 5.1
- Allow for non-card payment types in Subscription Create #327

### Bug Fixes
- `PayolaPaymentForm.poll()` handles HTTP error responses. #310


## v1.5.0 - 2016-10-27
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.4.0...v1.5.0)

### Security
- Raise error if `payola_can_modify_customer/subscription?` unimplemented. #246

### Enhancements
- Unpegged Stripe gem and stripe-ruby-mock. #255
- Take optional `stripe_customer_id` when creating a sale. #183
- Clean up error target HTML attributes. #198
- Update `cancel_at_period_end` in `CancelSubscription` service. #200
- Synchronize subscription amount and currency fields with Stripe. #202
- Send the `plan_id` along with the form submission. #206
- Set a customer's payment source if nil. #210
- Maintain the active coupon code on a subscription. #211
- Disallow deleting a plan if it has any related subscriptions. #221
- Flash message i18n. #229
- Rails 5.0 support. #232
- Add client side validation to subscription_form_onestep.js. #262

### Bug Fixes
- Stop setting `Stripe.api_key` directly in `CancelSubscription` service. #201
- Convert tax_percent from integer to decimal (at most two decimal places). #189
- Submit all subscription options for existing stripe customers. #207
- Update subscription quantity when a subscription is changed. #218
- Fix flash message typo 'Successfully'. #228
- Make tax percentage migration reversible. #242
- Call `instrument_quantity_changed` from `ChangeSubscriptionQuantity`. #250
- Fix api_key String spec errors with stripe-ruby-mock 2.3.1. #261
- Ensure ENV keys are seen as Strings by recent stripe-ruby versions. #265

## v1.4.0 - 2016-01-28
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.3.2...v1.4.0)

### Enhancements
- Add a wrapper for the error function to pass xhr.responseJSON to checkout
  buttons.
- Support free trials and plans by allowing subscription creation without
  credit card. #144, #145
- Support cancelling subscription at period end. #146
- Trigger `error` event on Payola HTML elements when an error occurs. #147
- Allows coupon to be applied to changing subscription, and turns off prorating
  in that scenario per Stripe instructions. #150
- Support for subscription creation with trial_end and optional stripeToken. #151
- Add config option to determine whether to create plans in Stripe. #156
- Allow `Plan#trial_period_days` attribute to remain optional. #160
- Accept tax percentage for subscriptions. #167
- Functionality to manage multiple cards and update customer attributes. Includes optional authorization check `payola_can_modify_customer?`. #168
- Optionally include checkout.stripe.com assets with `include_stripe_checkout_assets`. #169
- Improve support for subscription `at_period_end`. #165
- Support reusing existing Stripe customer for subscriptions. #170
- Listen for customer.subscription.deleted webhooks and cancel the associated subscription. #172
- Show plan interval in description instead of hardcoding to 'month'. #176
- Support coupons in `subscriptions/_checkout` partial. #179
- Allow sales to be refunded on the client side. #181
- Introduce `return_to` to support custom return paths after customer/card actions. #180
- `StartSubscription` no longer requires Stripe token for free plans. #190
- Turbolinks compatibility. #191

### Bug Fixes
- Disable only Payola-related submit button(s) on page. #113
- Fix jQuery XHR JSON error handling. #159
- Ensure Payola.create_stripe_plans global gets set back to true. #164
- Registration form no longer uses hardcoded `/users` path. #171
- Remove debugging output in javascripts. #177
- Remove weird copy of StartSubscription service specs. #178
- Only cancel subscription in `SubscriptionDeleted` if it can be canceled. #186

## v1.3.2 - 2015-05-18
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.3.1...v1.3.2)

- Lock stripe-ruby-mock to v2.1.0 to work around test issues
- Properly bubble subscription errors up to the user
- Handle card declines
- Add bitcoin option to checkout button
- Move the Payola Pro message out of initializers

## v1.3.1 - 2015-03-18
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.3.0...v1.3.1)

- Fix a problem when creating subscription invoice payments
- Peg Stripe gem at 1.20.1 pending a fix to rebelidealist/stripe-ruby-mock#203

## v1.3.0 - 2015-02-28
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.2.7...v1.3.0)

- Support Stripe API version 2015-02-18

## v1.2.7 - 2015-02-28
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.2.6...v1.2.7)

- Fix Javascript error handling for one-step subscriptions
- Add some docs about events and turbolinks incompatibility
- Support namespaced models for plans

## v1.2.6 - 2015-01-26
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.2.5...v1.2.6)

- Fix Javascript error handling for subscriptions

## v1.2.5 - 2015-01-25
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.2.4...v1.2.5)

- Capure all attributes from Stripe when starting a subscription
- Allow for use of Checkout for Subscriptions
- Only re-use active or canceled subscriptions
- Make plan creation idempotent

## v1.2.4 - 2015-01-06
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.2.3...v1.2.4)

- Fix regressions in v1.2.3

## v1.2.3 - 2015-01-03
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.2.2...v1.2.3)

- Add support for Rails 4.2
- Re-use customers and create invoice items for setup fees
- Add an active flag on `Payola::Coupon`
- Fix load-order problems
- Add support for subscription quantities
- Properly handle form errors

## v1.2.2 - 2014-11-29
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.2.1...v1.2.2)

- Optionally invert subscription controller flow
- Fix the CSRF token behavior

## v1.2.1 - 2014-11-20
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.2.0...v1.2.1)

- Make guid generator overrideable
- Bumped minimum version of AASM to 4.0
- Fixed a bug with the auto emails not working for webhook events
- Code cleanup
- Test coverage improvements

## v1.2.0 - 2014-11-17
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.1.4...v1.2.0)

- Subscriptions

## v1.1.4 - 2014-11-07
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.1.3...v1.1.4)

- Pass the created customer to `additional_charge_attributes`
- Add Payola Pro license

## v1.1.3 - 2014-11-07
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.1.2...v1.1.3)

- Add options for requesting billing and shipping addresses via Checkout
- Add a callable to add additional attributes to a Stripe::Charge
- Only talk about PDFs if PDFs are enabled

## v1.1.2 - 2014-11-06
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.1.1...v1.1.2)

- Default the `From` address on receipt emails to `Payola.support_email`

## v1.1.1 - 2014-11-03
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.1.0...v1.1.1)

- ActiveJob can't serialize a class or a symbol so we have to `to_s` them

## v1.1.0 - 2014-11-03
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.0.8...v1.1.0)

- Add customizable mailers
- Pass currency through properly and add a `default_currency` config option
- Use data attributes to set up the checkout button instead of a JS snippet
- Add a polymorphic `owner` association on `Payola::Sale`.
- Allow the price to be overridden on the Checkout form

## v1.0.8 - 2014-10-27
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.0.7...v1.0.8)

- Add basic support for custom forms
- Allow passing signed data from checkout button into the charge verifier
- Correctly pass the price into the Checkout button, which allows the `{{amount}}` macro to work properly
- I18n the formatted_price helper

## v1.0.7 - 2014-10-21
[Full Changelog](https://github.com/peterkeen/payola/compare/v1.0.6...v1.0.7)

- Add support for ActiveJob workers
- Document how to set Stripe keys
- Add a callback to fetch the publishable key
- Unpin the Rails version to allow anything >= 4.1
- Allow Payola to be mounted anywhere, as long as it has 'as: :payola' in the mount spec

## v1.0.6 - 2014-10-19
- First public release
