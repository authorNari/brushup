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

ActiveRecord::Schema.define(:version => 20120815151905) do

  create_table "configurations", :force => true do |t|
    t.string   "email",            :default => "brushup@example.com", :null => false
    t.string   "google_analytics", :default => "",                    :null => false
    t.string   "google_adsense",   :default => "",                    :null => false
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
  end

  create_table "openid_associations", :force => true do |t|
    t.datetime "issued_at"
    t.integer  "lifetime"
    t.string   "assoc_type"
    t.text     "handle"
    t.binary   "secret"
    t.string   "target"
    t.text     "server_url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "openid_nonces", :force => true do |t|
    t.integer  "timestamp"
    t.string   "salt"
    t.string   "target"
    t.text     "server_url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "reminders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "schedule_id"
    t.string   "title"
    t.text     "body"
    t.boolean  "completed"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.date     "learned_at"
    t.date     "next_learn_date"
    t.string   "format"
  end

  create_table "schedules", :force => true do |t|
    t.integer  "level"
    t.integer  "span"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.string   "context",       :limit => 128
    t.integer  "tagger_id"
    t.string   "tagger_type"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "openid_url"
    t.string   "login"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "default_format"
  end

end
