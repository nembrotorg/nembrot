class Authorization < ActiveRecord::Base
  belongs_to :user

  attr_accessor :name, :email

  serialize :extra, Hash

  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, scope: :provider
end
