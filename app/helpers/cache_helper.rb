# encoding: utf-8

module CacheHelper
  def cache_buster(version)
    "#{ NB }#{ version }"
  end
end
