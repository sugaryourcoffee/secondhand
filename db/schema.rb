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

ActiveRecord::Schema.define(version: 20170404050221) do

  create_table "carts", force: true do |t|
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "cart_type",  default: "SALES"
    t.integer  "user_id"
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id"

  create_table "conditions", force: true do |t|
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
  end

  create_table "events", force: true do |t|
    t.string   "title"
    t.datetime "event_date"
    t.string   "location"
    t.decimal  "fee",                   precision: 5, scale: 2
    t.decimal  "deduction",             precision: 5, scale: 2
    t.decimal  "provision",             precision: 4, scale: 2
    t.integer  "max_lists"
    t.integer  "max_items_per_list"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.boolean  "active",                                        default: false
    t.date     "list_closing_date"
    t.date     "delivery_date"
    t.time     "delivery_start_time"
    t.time     "delivery_end_time"
    t.string   "delivery_location"
    t.date     "collection_date"
    t.time     "collection_start_time"
    t.time     "collection_end_time"
    t.string   "collection_location"
    t.string   "information"
    t.string   "alert_terms"
    t.integer  "alert_value",                                   default: 20
  end

  create_table "items", force: true do |t|
    t.integer  "item_number"
    t.string   "description"
    t.string   "size"
    t.decimal  "price",       precision: 5, scale: 2
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "list_id"
  end

  create_table "line_items", force: true do |t|
    t.integer  "item_id"
    t.integer  "cart_id"
    t.integer  "reversal_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "selling_id"
  end

  create_table "lists", force: true do |t|
    t.integer  "list_number"
    t.string   "registration_code"
    t.string   "container"
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "sent_on"
    t.datetime "accepted_on"
    t.datetime "labels_printed_on"
  end

  create_table "news", force: true do |t|
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "user_id"
    t.string   "issue"
    t.boolean  "promote_to_frontpage"
    t.boolean  "released"
    t.datetime "sent_on"
  end

  create_table "news_translations", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "language"
    t.integer  "news_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "pages", force: true do |t|
    t.integer  "number"
    t.string   "title"
    t.text     "content"
    t.integer  "terms_of_use_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["terms_of_use_id"], name: "index_pages_on_terms_of_use_id"

  create_table "reversals", force: true do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "event_id"
  end

  create_table "sellings", force: true do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "event_id"
  end

  create_table "terms_of_uses", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conditions_id"
    t.string   "locale"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "street"
    t.string   "zip_code"
    t.string   "town"
    t.string   "country"
    t.string   "phone"
    t.string   "email"
    t.string   "password_digest"
    t.boolean  "news"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "remember_token"
    t.boolean  "admin",                  default: false
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "preferred_language"
    t.boolean  "operator",               default: false
    t.datetime "terms_of_use"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
