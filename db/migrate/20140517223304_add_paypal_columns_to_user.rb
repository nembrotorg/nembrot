class AddPaypalColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :expires_at, :datetime
    add_column :users, :paypal_last_ipn, :string
    add_column :users, :country, :string
    add_column :users, :paypal_payer_id, :string
    add_column :users, :paypal_subscriber_id, :string
    add_column :users, :token_for_paypal, :string
  end
end
