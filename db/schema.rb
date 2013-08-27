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

ActiveRecord::Schema.define(:version => 20130827193649) do

  create_table "books", :force => true do |t|
    t.string   "title"
    t.string   "author"
    t.string   "translator"
    t.string   "introducer"
    t.string   "editor"
    t.string   "lang"
    t.date     "published_date"
    t.string   "published_city"
    t.string   "publisher"
    t.string   "isbn_10"
    t.string   "isbn_13"
    t.string   "format"
    t.integer  "page_count"
    t.string   "dimensions"
    t.string   "weight"
    t.string   "google_books_id"
    t.string   "tag"
    t.boolean  "dirty"
    t.integer  "attempts"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.string   "library_thing_id"
    t.string   "open_library_id"
    t.string   "slug"
    t.string   "dewey_decimal"
    t.string   "lcc_number"
    t.string   "full_text_url"
    t.boolean  "google_books_embeddable"
  end

  add_index "books", ["slug"], :name => "index_sources_on_slug", :unique => true

  create_table "books_notes", :force => true do |t|
    t.integer "book_id"
    t.integer "note_id"
  end

  create_table "evernote_auths", :force => true do |t|
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.text     "auth"
    t.text     "encrypted_auth"
  end

  create_table "evernote_notes", :force => true do |t|
    t.string   "cloud_note_identifier"
    t.integer  "note_id"
    t.integer  "evernote_auth_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "dirty"
    t.integer  "attempts"
    t.binary   "content_hash",           :limit => 255
    t.integer  "update_sequence_number"
  end

  add_index "evernote_notes", ["cloud_note_identifier", "evernote_auth_id"], :name => "index_cloud_notes_on_identifier_service_id", :unique => true
  add_index "evernote_notes", ["note_id"], :name => "index_cloud_notes_on_note_id"

  create_table "links", :force => true do |t|
    t.string   "title"
    t.string   "website_name"
    t.string   "author"
    t.string   "lang"
    t.date     "modified"
    t.string   "url"
    t.string   "canonical_url"
    t.boolean  "error"
    t.boolean  "paywall"
    t.string   "publisher"
    t.boolean  "dirty"
    t.integer  "attempts"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.float    "altitude"
    t.string   "channel"
    t.string   "slug"
  end

  add_index "links", ["slug"], :name => "index_links_on_slug", :unique => true

  create_table "links_notes", :force => true do |t|
    t.integer "link_id"
    t.integer "note_id"
  end

  create_table "notes", :force => true do |t|
    t.string   "title",                                               :null => false
    t.text     "body"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.datetime "external_updated_at",                                 :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.float    "altitude"
    t.string   "lang",                :limit => 2
    t.boolean  "active"
    t.string   "author"
    t.string   "source"
    t.string   "source_url"
    t.string   "source_application"
    t.string   "last_edited_by"
    t.boolean  "hide"
    t.boolean  "is_citation",                      :default => false
    t.boolean  "listable",                         :default => true
    t.integer  "word_count"
  end

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
    t.integer  "attempts"
    t.integer  "note_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.binary   "data_hash"
    t.integer  "width"
    t.integer  "height"
    t.integer  "size"
    t.string   "local_file_name"
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
    t.string   "item_type",                       :null => false
    t.integer  "item_id",                         :null => false
    t.string   "event",                           :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.integer  "sequence"
    t.text     "tag_list"
    t.text     "instruction_list", :limit => 255
    t.integer  "word_count"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
