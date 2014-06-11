class AddStillMorePaypalColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_ipn_txn_type, :string
    add_column :users, :subscription_term_days, :integer
    add_column :users, :paypal_cancelled_at, :datetime
  end
end
