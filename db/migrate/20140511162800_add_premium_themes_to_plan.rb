class AddPremiumThemesToPlan < ActiveRecord::Migration
  def change
    add_column :plans, :premium_themes, :boolean, default: false
  end
end
