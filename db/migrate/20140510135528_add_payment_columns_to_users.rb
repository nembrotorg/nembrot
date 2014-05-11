class AddPaymentColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :next_payment_due_at, :datetime
    add_column :users, :payment_status, :boolean
    add_column :users, :payment_status_updated_at, :datetime
    add_column :users, :plan_id, :integer, null: false, default: 0
  end
end
