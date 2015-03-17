module FollowUrlsHelper
  def url_pattern(service)
    "[a-zA-Z0-9\-\_\:\/\.]{0,40}#{ service }[a-zA-Z0-9\-\_\:\/\.]{3,60}"
  end

  def email_pattern
    "[a-zA-Z0-9\-\_\.]{1,60}@[a-z\-\_\.]{1,60}\.[a-z\.]{2,10}"
  end

  def follow_url(url)
    !url.match(/https?:\/\//).nil? ? url : "http://#{ url }"
  end
end
