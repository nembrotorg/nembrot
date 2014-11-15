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

ActiveRecord::Schema.define(version: 20141115183149) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorizations", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.string   "nickname"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "extra"
    t.text     "key"
  end

  create_table "books", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "library_thing_id"
    t.string   "open_library_id"
    t.string   "slug"
    t.string   "dewey_decimal"
    t.string   "lcc_number"
    t.string   "full_text_url"
    t.boolean  "google_books_embeddable"
    t.datetime "try_again_at"
  end

  add_index "books", ["slug"], name: "index_books_on_slug", unique: true, using: :btree

  create_table "books_notes", force: true do |t|
    t.integer "book_id"
    t.integer "note_id"
  end

  create_table "channels", force: true do |t|
    t.string   "name"
    t.text     "notebooks"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.integer  "theme_id"
    t.boolean  "always_reset_on_create",    default: true
    t.boolean  "bibliography",              default: false
    t.string   "contact_email"
    t.string   "disqus_shortname"
    t.string   "facebook_app_id"
    t.string   "follow_on_facebook"
    t.string   "follow_on_soundcloud"
    t.string   "follow_on_tumblr"
    t.string   "follow_on_twitter"
    t.string   "follow_on_vimeo"
    t.string   "follow_on_youtube"
    t.string   "google_analytics_key"
    t.boolean  "index_on_google",           default: true
    t.boolean  "links_section",             default: false
    t.string   "locale",                    default: "en"
    t.boolean  "only_show_notes_in_locale", default: false
    t.boolean  "private",                   default: false
    t.boolean  "promote",                   default: true
    t.boolean  "show_nembrot_link",         default: true
    t.string   "url"
    t.boolean  "versions",                  default: false
    t.boolean  "comments",                  default: true
    t.boolean  "active",                    default: true
    t.boolean  "breadcrumbs",               default: true
    t.boolean  "menu_at_top",               default: true
    t.boolean  "menu_at_bottom",            default: true
    t.string   "follow_on_googleplus"
    t.boolean  "promoted",                  default: false
    t.boolean  "tags",                      default: true
    t.boolean  "locale_auto",               default: true
    t.text     "copyright"
    t.boolean  "notes_index",               default: true
    t.integer  "read_more_notes",           default: 10
    t.boolean  "has_notes",                 default: false
    t.string   "follow_on_github"
    t.string   "follow_on_instagram"
    t.string   "follow_on_pinterest"
    t.string   "follow_on_flickr"
  end

  add_index "channels", ["slug"], name: "index_channels_on_slug", unique: true, using: :btree

  create_table "commontator_comments", force: true do |t|
    t.string   "creator_type"
    t.integer  "creator_id"
    t.string   "editor_type"
    t.integer  "editor_id"
    t.integer  "thread_id",                      null: false
    t.text     "body",                           null: false
    t.datetime "deleted_at"
    t.integer  "cached_votes_total", default: 0
    t.integer  "cached_votes_up",    default: 0
    t.integer  "cached_votes_down",  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_comments", ["cached_votes_down"], name: "index_commontator_comments_on_cached_votes_down", using: :btree
  add_index "commontator_comments", ["cached_votes_total"], name: "index_commontator_comments_on_cached_votes_total", using: :btree
  add_index "commontator_comments", ["cached_votes_up"], name: "index_commontator_comments_on_cached_votes_up", using: :btree
  add_index "commontator_comments", ["creator_type", "creator_id", "thread_id"], name: "index_c_c_on_c_type_and_c_id_and_t_id", using: :btree
  add_index "commontator_comments", ["thread_id"], name: "index_commontator_comments_on_thread_id", using: :btree

  create_table "commontator_subscriptions", force: true do |t|
    t.string   "subscriber_type",             null: false
    t.integer  "subscriber_id",               null: false
    t.integer  "thread_id",                   null: false
    t.integer  "unread",          default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_subscriptions", ["subscriber_type", "subscriber_id", "thread_id"], name: "index_c_s_on_s_type_and_s_id_and_t_id", unique: true, using: :btree
  add_index "commontator_subscriptions", ["thread_id"], name: "index_commontator_subscriptions_on_thread_id", using: :btree

  create_table "commontator_threads", force: true do |t|
    t.string   "commontable_type"
    t.integer  "commontable_id"
    t.datetime "closed_at"
    t.string   "closer_type"
    t.integer  "closer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_threads", ["commontable_type", "commontable_id"], name: "index_c_t_on_c_type_and_c_id", unique: true, using: :btree

  create_table "evernote_notes", force: true do |t|
    t.string   "cloud_note_identifier"
    t.integer  "note_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "dirty"
    t.integer  "attempts"
    t.binary   "content_hash"
    t.integer  "update_sequence_number"
    t.datetime "try_again_at"
    t.text     "cloud_notebook_identifier"
  end

  add_index "evernote_notes", ["note_id"], name: "index_evernote_notes_on_note_id", using: :btree

  create_table "links", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "latitude"
    t.float    "longitude"
    t.float    "altitude"
    t.string   "channel"
    t.string   "slug"
    t.datetime "try_again_at"
  end

  add_index "links", ["slug"], name: "index_links_on_slug", unique: true, using: :btree

  create_table "links_notes", force: true do |t|
    t.integer "link_id"
    t.integer "note_id"
  end

  create_table "notes", force: true do |t|
    t.string   "title",                                         null: false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "external_updated_at",                           null: false
    t.float    "latitude"
    t.float    "longitude"
    t.float    "altitude"
    t.string   "lang",                limit: 2
    t.boolean  "active"
    t.string   "author"
    t.string   "source"
    t.string   "source_url"
    t.string   "source_application"
    t.string   "last_edited_by"
    t.boolean  "hide"
    t.boolean  "is_citation",                   default: false
    t.boolean  "listable",                      default: true
    t.integer  "word_count"
    t.integer  "distance"
    t.string   "place"
    t.string   "content_class"
    t.text     "introduction"
    t.string   "feature"
    t.string   "feature_id"
    t.boolean  "is_feature"
    t.boolean  "is_section"
    t.boolean  "is_mapped"
    t.boolean  "is_promoted"
    t.integer  "weight"
  end

  create_table "plans", force: true do |t|
    t.boolean  "active",                  default: true
    t.boolean  "advanced_settings",       default: false
    t.boolean  "business_notebooks",      default: false
    t.boolean  "hd_images",               default: false
    t.boolean  "image_effects",           default: false
    t.boolean  "shared_notebooks",        default: false
    t.boolean  "url",                     default: false
    t.integer  "annual_fee_eur",          default: 0
    t.integer  "annual_fee_gbp",          default: 0
    t.integer  "annual_fee_usd",          default: 0
    t.integer  "max_channels",            default: 1
    t.integer  "monthly_fee_eur",         default: 0
    t.integer  "monthly_fee_gbp",         default: 0
    t.integer  "monthly_fee_usd",         default: 0
    t.string   "name"
    t.string   "paypal_code_annual_eur"
    t.string   "paypal_code_annual_gbp"
    t.string   "paypal_code_annual_usd"
    t.string   "paypal_code_monthly_eur"
    t.string   "paypal_code_monthly_gbp"
    t.string   "paypal_code_monthly_usd"
    t.string   "reference"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "premium_themes",          default: false
  end

  create_table "related_notes", force: true do |t|
    t.integer  "note_id"
    t.integer  "related_note_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resources", force: true do |t|
    t.string   "cloud_resource_identifier"
    t.string   "mime"
    t.text     "caption"
    t.text     "description"
    t.text     "credit"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "data_hash"
    t.integer  "width"
    t.integer  "height"
    t.integer  "size"
    t.string   "local_file_name"
    t.datetime "try_again_at"
  end

  add_index "resources", ["cloud_resource_identifier", "note_id"], name: "index_resources_on_cloud_resource_identifier_and_note_id", unique: true, using: :btree
  add_index "resources", ["note_id"], name: "index_resources_on_note_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: true do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
    t.string "slug"
  end

  add_index "tags", ["slug"], name: "index_tags_on_slug", unique: true, using: :btree

  create_table "themes", force: true do |t|
    t.boolean  "premium"
    t.boolean  "public"
    t.string   "effects"
    t.string   "map_style"
    t.string   "name"
    t.string   "slug"
    t.string   "typekit_code"
    t.boolean  "suitable_for_text"
    t.boolean  "suitable_for_images"
    t.boolean  "suitable_for_maps"
    t.boolean  "suitable_for_video_and_sound"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "css"
  end

  create_table "users", force: true do |t|
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.string   "location"
    t.string   "name"
    t.string   "nickname"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "image"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "remember_token"
    t.integer  "plan_id",                default: 0,    null: false
    t.string   "paypal_email"
    t.string   "paypal_last_ipn"
    t.string   "country"
    t.string   "paypal_payer_id"
    t.string   "paypal_subscriber_id"
    t.string   "token_for_paypal"
    t.string   "paypal_last_tx"
    t.datetime "downgrade_warning_at"
    t.datetime "downgrade_at"
    t.string   "last_ipn_txn_type"
    t.integer  "subscription_term_days"
    t.datetime "paypal_cancelled_at"
    t.boolean  "newsletter",             default: true
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",           null: false
    t.integer  "item_id",             null: false
    t.string   "event",               null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.integer  "sequence"
    t.text     "tag_list"
    t.text     "instruction_list"
    t.integer  "word_count"
    t.datetime "external_updated_at"
    t.integer  "distance"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "votes", force: true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

end
