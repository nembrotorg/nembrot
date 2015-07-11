# encoding: utf-8

class ColophonController < ApplicationController
  def index
    @palette = Setting.where("var LIKE '%color%'").pluck(:value).uniq
    @gems = Bundler.load.specs.sort_by &:name
  end
end
