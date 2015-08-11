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

ActiveRecord::Schema.define(version: 20150531093811) do

  create_table "authorizations", force: :cascade do |t|
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.integer  "user_id"
    t.string   "nickname",   limit: 255
    t.string   "token",      limit: 255
    t.string   "secret",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "extra"
    t.text     "key"
  end

  create_table "books", force: :cascade do |t|
    t.string   "title",                   limit: 255
    t.string   "author",                  limit: 255
    t.string   "translator",              limit: 255
    t.string   "introducer",              limit: 255
    t.string   "editor",                  limit: 255
    t.string   "lang",                    limit: 255
    t.date     "published_date"
    t.string   "published_city",          limit: 255
    t.string   "publisher",               limit: 255
    t.string   "isbn_10",                 limit: 255
    t.string   "isbn_13",                 limit: 255
    t.string   "format",                  limit: 255
    t.integer  "page_count"
    t.string   "dimensions",              limit: 255
    t.string   "weight",                  limit: 255
    t.string   "google_books_id",         limit: 255
    t.string   "tag",                     limit: 255
    t.boolean  "dirty"
    t.integer  "attempts"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "library_thing_id",        limit: 255
    t.string   "open_library_id",         limit: 255
    t.string   "slug",                    limit: 255
    t.string   "dewey_decimal",           limit: 255
    t.string   "lcc_number",              limit: 255
    t.string   "full_text_url",           limit: 255
    t.boolean  "google_books_embeddable"
    t.datetime "try_again_at"
  end

  add_index "books", ["slug"], name: "index_sources_on_slug", unique: true

  create_table "books_notes", force: :cascade do |t|
    t.integer "book_id"
    t.integer "note_id"
  end

  create_table "commontator_comments", force: :cascade do |t|
    t.string   "creator_type",       limit: 255
    t.integer  "creator_id"
    t.string   "editor_type",        limit: 255
    t.integer  "editor_id"
    t.integer  "thread_id",                                  null: false
    t.text     "body",                                       null: false
    t.datetime "deleted_at"
    t.integer  "cached_votes_total",             default: 0
    t.integer  "cached_votes_up",                default: 0
    t.integer  "cached_votes_down",              default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_comments", ["cached_votes_down"], name: "index_commontator_comments_on_cached_votes_down"
  add_index "commontator_comments", ["cached_votes_total"], name: "index_commontator_comments_on_cached_votes_total"
  add_index "commontator_comments", ["cached_votes_up"], name: "index_commontator_comments_on_cached_votes_up"
  add_index "commontator_comments", ["creator_type", "creator_id", "thread_id"], name: "index_c_c_on_c_type_and_c_id_and_t_id"
  add_index "commontator_comments", ["thread_id"], name: "index_commontator_comments_on_thread_id"

  create_table "commontator_subscriptions", force: :cascade do |t|
    t.string   "subscriber_type", limit: 255,             null: false
    t.integer  "subscriber_id",                           null: false
    t.integer  "thread_id",                               null: false
    t.integer  "unread",                      default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_subscriptions", ["subscriber_type", "subscriber_id", "thread_id"], name: "index_c_s_on_s_type_and_s_id_and_t_id", unique: true
  add_index "commontator_subscriptions", ["thread_id"], name: "index_commontator_subscriptions_on_thread_id"

  create_table "commontator_threads", force: :cascade do |t|
    t.string   "commontable_type", limit: 255
    t.integer  "commontable_id"
    t.datetime "closed_at"
    t.string   "closer_type",      limit: 255
    t.integer  "closer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_threads", ["commontable_type", "commontable_id"], name: "index_c_t_on_c_type_and_c_id", unique: true

  create_table "evernote_notes", force: :cascade do |t|
    t.string   "cloud_note_identifier",     limit: 255
    t.integer  "note_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "dirty"
    t.integer  "attempts"
    t.binary   "content_hash"
    t.integer  "update_sequence_number"
    t.datetime "try_again_at"
    t.text     "cloud_notebook_identifier"
  end

  add_index "evernote_notes", ["note_id"], name: "index_cloud_notes_on_note_id"

  create_table "notes", force: :cascade do |t|
    t.string   "title",               limit: 255,                 null: false
    t.text     "body"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.datetime "external_updated_at",                             null: false
    t.float    "latitude"
    t.float    "longitude"
    t.float    "altitude"
    t.string   "lang",                limit: 2
    t.boolean  "active"
    t.string   "author",              limit: 255
    t.string   "source",              limit: 255
    t.string   "source_url",          limit: 255
    t.string   "source_application",  limit: 255
    t.string   "last_edited_by",      limit: 255
    t.boolean  "hide"
    t.boolean  "is_citation",                     default: false
    t.boolean  "listable",                        default: true
    t.integer  "word_count"
    t.integer  "distance"
    t.string   "place",               limit: 255
    t.string   "content_class",       limit: 255
    t.text     "introduction"
    t.string   "feature",             limit: 255
    t.string   "feature_id",          limit: 255
    t.boolean  "is_feature"
    t.boolean  "is_section"
    t.boolean  "is_mapped"
    t.boolean  "is_promoted"
    t.integer  "weight"
    t.integer  "content_type",                    default: 0,     null: false
    t.string   "url"
    t.string   "url_author"
    t.binary   "url_html"
    t.text     "url_lede"
    t.string   "url_title"
    t.datetime "url_updated_at"
    t.datetime "url_accessed_at"
    t.string   "url_lang"
    t.string   "url_domain"
  end

  create_table "pantographers", force: :cascade do |t|
    t.string   "twitter_screen_name", limit: 255
    t.string   "twitter_real_name",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "twitter_user_id",     limit: 8
  end

  create_table "pantographs", force: :cascade do |t|
    t.string   "text",                limit: 140
    t.datetime "external_created_at"
    t.integer  "pantographer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tweet_id",            limit: 8
  end

  create_table "rails_admin_histories", force: :cascade do |t|
    t.text     "message"
    t.string   "username",   limit: 255
    t.integer  "item"
    t.string   "table",      limit: 255
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories"

  create_table "resources", force: :cascade do |t|
    t.string   "cloud_resource_identifier", limit: 255
    t.string   "mime",                      limit: 255
    t.text     "caption"
    t.text     "description"
    t.text     "credit"
    t.string   "source_url",                limit: 255
    t.datetime "external_updated_at"
    t.float    "latitude"
    t.float    "longitude"
    t.float    "altitude"
    t.string   "camera_make",               limit: 255
    t.string   "camera_model",              limit: 255
    t.string   "file_name",                 limit: 255
    t.boolean  "attachment"
    t.boolean  "dirty"
    t.integer  "attempts"
    t.integer  "note_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.binary   "data_hash"
    t.integer  "width"
    t.integer  "height"
    t.integer  "size"
    t.string   "local_file_name",           limit: 255
    t.datetime "try_again_at"
  end

  add_index "resources", ["cloud_resource_identifier", "note_id"], name: "index_resources_on_cloud_resource_identifier_and_note_id", unique: true
  add_index "resources", ["note_id"], name: "index_resources_on_note_id"

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "settings", force: :cascade do |t|
    t.string   "var",        limit: 255, null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.string  "slug",           limit: 255
    t.integer "taggings_count",             default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true
  add_index "tags", ["slug"], name: "index_tags_on_slug", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "role",                   limit: 255
    t.string   "location",               limit: 255
    t.string   "name",                   limit: 255
    t.string   "nickname",               limit: 255
    t.string   "email",                  limit: 255
    t.string   "encrypted_password",     limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "image",                  limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.string   "remember_token",         limit: 255
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",           limit: 255, null: false
    t.integer  "item_id",                         null: false
    t.string   "event",               limit: 255, null: false
    t.string   "whodunnit",           limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.integer  "sequence"
    t.text     "tag_list"
    t.text     "instruction_list"
    t.integer  "word_count"
    t.datetime "external_updated_at"
    t.integer  "distance"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id"
    t.string   "votable_type", limit: 255
    t.integer  "voter_id"
    t.string   "voter_type",   limit: 255
    t.boolean  "vote_flag"
    t.string   "vote_scope",   limit: 255
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"

end
