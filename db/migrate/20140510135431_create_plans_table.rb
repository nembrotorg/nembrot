class CreatePlansTable < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.belongs_to :user
      t.boolean    :active, default: true
      t.boolean    :advanced_settings, default: false
      t.boolean    :business_notebooks, default: false
      t.boolean    :hd_images, default: false
      t.boolean    :image_effects, default: false
      t.boolean    :shared_notebooks, default: false
      t.boolean    :url, default: false
      t.integer    :annual_fee_eur, default: 0
      t.integer    :annual_fee_gbp, default: 0
      t.integer    :annual_fee_usd, default: 0
      t.integer    :max_channels, default: 1
      t.integer    :monthly_fee_eur, default: 0
      t.integer    :monthly_fee_gbp, default: 0
      t.integer    :monthly_fee_usd, default: 0
      t.string     :paypal_code_annual_eur
      t.string     :paypal_code_annual_gbp
      t.string     :paypal_code_annual_usd
      t.string     :paypal_code_monthly_eur
      t.string     :paypal_code_monthly_gbp
      t.string     :paypal_code_monthly_usd
      t.timestamps
    end
  end
end
