# encoding: utf-8

module Mergeable
  extend ActiveSupport::Concern

  module ClassMethods
    def set_unless_blank(attribute, value)
      attribute = value unless value.blank?
    end
  end
end
