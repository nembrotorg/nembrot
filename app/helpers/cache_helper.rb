# encoding: utf-8

module CacheHelper
  def cache_buster(version)
    "#{ Setting.all.load }#{ version }"
  end
end
