class AddLanguageToLink < ActiveRecord::Migration
  def change
    add_column :notes, :url_lang, :string
  end
end
