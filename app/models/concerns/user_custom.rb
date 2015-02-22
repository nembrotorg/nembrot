# encoding: utf-8

module UserCustom
  extend ActiveSupport::Concern

  included do
    has_many :channels, dependent: :destroy
  end
end
