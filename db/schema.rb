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

ActiveRecord::Schema.define(:version => 20130122113434) do

  create_table "cloud_notes", :force => true do |t|
    t.string   "cloud_note_identifier"
    t.integer  "note_id"
    t.integer  "cloud_service_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "dirty"
    t.integer  "sync_retries"
    t.binary   "content_hash",          :limit => 255
  end

  add_index "cloud_notes", ["cloud_note_identifier", "cloud_service_id"], :name => "index_cloud_notes_on_identifier_service_id", :unique => true
  add_index "cloud_notes", ["note_id"], :name => "index_cloud_notes_on_note_id"

  create_table "cloud_services", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.text     "auth"
    t.text     "encrypted_auth"
  end

  create_table "notes", :force => true do |t|
    t.string   "title",                            :null => false
    t.text     "body",                             :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.datetime "external_updated_at",              :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.float    "altitude"
    t.boolean  "gmaps"
    t.string   "lang",                :limit => 2
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 5
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "resources", :force => true do |t|
    t.string   "cloud_resource_identifier"
    t.string   "mime"
    t.string   "caption"
    t.string   "description"
    t.string   "credit"
    t.string   "source_url"
    t.datetime "external_updated_at"
    t.float    "latitude"
    t.float    "longitude"
    t.float    "altitude"
    t.string   "camera_make"
    t.string   "camera_model"
    t.string   "file_name"
    t.boolean  "attachment"
    t.boolean  "dirty"
    t.integer  "sync_retries"
    t.integer  "note_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.binary   "data_hash"
    t.integer  "width"
    t.integer  "height"
    t.integer  "size"
    t.boolean  "gmaps"
  end

  add_index "resources", ["note_id"], :name => "index_resources_on_note_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
    t.string "slug"
  end

  add_index "tags", ["slug"], :name => "index_tags_on_slug", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.integer  "sequence"
    t.text     "tags"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
