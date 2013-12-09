# encoding: utf-8

module Mergeable
  extend ActiveSupport::Concern

  def set_unless_blank(a, b)
    a = b unless b.blank?
  end
end
