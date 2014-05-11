class Plan < ActiveRecord::Base

  has_paper_trail

  validates :name, :reference, uniqueness: true

  before_validation :update_reference, if: :name_changed?, unless: :reference_changed?

  def self.free
    where(name: 'Free').first_or_create
  end

  private

  def update_reference
    self.reference = name
  end
end
