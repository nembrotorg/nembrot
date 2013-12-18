class Authorization < ActiveRecord::Base
  belongs_to :user

  serialize :extra, Hash

  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, scope: :provider
end
