# encoding: utf-8

module CacheHelper
  def cache_buster(version)
    "#{ Setting['advanced.cache_buster'] }#{ version }"
  end
end
