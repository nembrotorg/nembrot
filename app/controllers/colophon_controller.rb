# encoding: utf-8

class ColophonController < ApplicationController
  def index
    color_settings = ENV.select { |x| x.match(/.*color.*/) }
    @palette = color_settings.values.uniq
    @gems = Bundler.load.specs.sort_by &:name
  end
end
