class AddAdvancedSettingsToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :always_reset_on_create, :boolean, default: true
    add_column :channels, :bibliography, :boolean, default: false
    add_column :channels, :contact_email, :string
    add_column :channels, :disqus_shortname, :string
    add_column :channels, :facebook_app_id, :string
    add_column :channels, :follow_on_facebook, :string
    add_column :channels, :follow_on_soundcloud, :string
    add_column :channels, :follow_on_tumblr, :string
    add_column :channels, :follow_on_twitter, :string
    add_column :channels, :follow_on_vimeo, :string
    add_column :channels, :follow_on_youtube, :string
    add_column :channels, :google_analytics_key, :string
    add_column :channels, :index_on_google, :boolean, default: true
    add_column :channels, :links_section, :boolean, default: false
    add_column :channels, :locale, :string, default: 'en'
    add_column :channels, :only_show_notes_in_locale, :boolean, default: false
    add_column :channels, :private, :boolean, default: false
    add_column :channels, :promote, :boolean, default: true
    add_column :channels, :show_nembrot_link, :boolean, default: true
    add_column :channels, :url, :string
    add_column :channels, :versions, :boolean, default: false
  end
end
