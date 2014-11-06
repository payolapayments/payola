# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141106034610) do

  create_table "owners", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payola_affiliates", force: true do |t|
    t.string   "code"
    t.string   "email"
    t.integer  "percent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payola_coupons", force: true do |t|
    t.string   "code"
    t.integer  "percent_off"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payola_sales", force: true do |t|
    t.string   "email"
    t.string   "guid"
    t.integer  "product_id"
    t.string   "product_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.string   "stripe_id"
    t.string   "stripe_token"
    t.string   "card_last4"
    t.date     "card_expiration"
    t.string   "card_type"
    t.text     "error"
    t.integer  "amount"
    t.integer  "fee_amount"
    t.integer  "coupon_id"
    t.boolean  "opt_in"
    t.integer  "download_count"
    t.integer  "affiliate_id"
    t.text     "customer_address"
    t.text     "business_address"
    t.string   "stripe_customer_id"
    t.string   "currency"
    t.text     "signed_custom_fields"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "payola_sales", ["coupon_id"], name: "index_payola_sales_on_coupon_id"
  add_index "payola_sales", ["email"], name: "index_payola_sales_on_email"
  add_index "payola_sales", ["guid"], name: "index_payola_sales_on_guid"
  add_index "payola_sales", ["owner_id", "owner_type"], name: "index_payola_sales_on_owner_id_and_owner_type"
  add_index "payola_sales", ["product_id", "product_type"], name: "index_payola_sales_on_product"
  add_index "payola_sales", ["stripe_customer_id"], name: "index_payola_sales_on_stripe_customer_id"

  create_table "payola_stripe_webhooks", force: true do |t|
    t.string   "stripe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payola_subscriptions", force: true do |t|
    t.string   "plan_type"
    t.integer  "plan_id"
    t.datetime "start"
    t.string   "status"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "stripe_customer_id"
    t.boolean  "cancel_at_period_end"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.datetime "ended_at"
    t.datetime "trial_start"
    t.datetime "trial_end"
    t.datetime "canceled_at"
    t.integer  "quantity"
    t.string   "stripe_id"
    t.string   "stripe_token"
    t.string   "card_last4"
    t.date     "card_expiration"
    t.string   "card_type"
    t.text     "error"
    t.string   "state"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency"
    t.integer  "amount"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.string   "permalink"
    t.integer  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_plans", force: true do |t|
    t.integer  "amount"
    t.string   "interval"
    t.integer  "interval_count"
    t.string   "name"
    t.string   "stripe_id"
    t.integer  "trial_period_days"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
