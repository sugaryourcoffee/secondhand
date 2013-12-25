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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131225060213) do

  create_table "events", :force => true do |t|
    t.string   "title"
    t.datetime "event_date"
    t.string   "location"
    t.decimal  "fee",                   :precision => 5, :scale => 2
    t.decimal  "deduction",             :precision => 5, :scale => 2
    t.decimal  "provision",             :precision => 4, :scale => 2
    t.integer  "max_lists"
    t.integer  "max_items_per_list"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.boolean  "active",                                              :default => false
    t.date     "list_closing_date"
    t.date     "delivery_date"
    t.time     "delivery_start_time"
    t.time     "delivery_end_time"
    t.string   "delivery_location"
    t.date     "collection_date"
    t.time     "collection_start_time"
    t.time     "collection_end_time"
    t.string   "collection_location"
  end

  create_table "items", :force => true do |t|
    t.integer  "item_number"
    t.string   "description"
    t.string   "size"
    t.decimal  "price",       :precision => 5, :scale => 2
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "list_id"
  end

  create_table "lists", :force => true do |t|
    t.integer  "list_number"
    t.string   "registration_code"
    t.string   "container"
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.datetime "sent_on"
  end

  create_table "news", :force => true do |t|
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "user_id"
    t.string   "issue"
    t.boolean  "promote_to_frontpage"
    t.boolean  "released"
  end

  create_table "news_translations", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "language"
    t.integer  "news_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
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
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "remember_token"
    t.boolean  "admin",                  :default => false
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
