class AddUrlDomainToLink < ActiveRecord::Migration
  def change
    add_column :notes, :url_domain, :string
  end
end
