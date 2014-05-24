class AddDowngradeColumnsToUser < ActiveRecord::Migration
  def change
    remove_column :users, :next_payment_due_at
    remove_column :users, :payment_status
    remove_column :users, :payment_status_updated_at

    add_column :users, :paypal_last_tx, :string
    add_column :users, :downgrade_warning_at, :datetime
    add_column :users, :downgrade_at, :datetime
  end
end
