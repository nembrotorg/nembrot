class Plan < ActiveRecord::Base

  has_paper_trail

  validates :name, :reference, uniqueness: true

  before_validation :update_reference, if: :name_changed?, unless: :reference_changed?

  def self.free
    where(name: 'Free').first_or_create
  end

  def self.find_from_payment(currency, amount)
    amount = (amount.to_f * 100).to_i

    case currency
      when 'EUR'
        where('plans.annual_fee_eur = ? OR plans.monthly_fee_eur = ?', amount, amount).first
      when 'GBP'
        where('plans.annual_fee_gbp = ? OR plans.monthly_fee_gbp = ?', amount, amount).first
      when 'USD'
        where('plans.annual_fee_usd = ? OR plans.monthly_fee_usd = ?', amount, amount).first
      else
        nil
    end
  end

  private

  def update_reference
    self.reference = name
  end
end
