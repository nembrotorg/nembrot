Constant.channel.map do |key, value|
  # Namespaced defaults don't work in rails-settings-cached gem
  # Setting.save_default("channel.#{ key }", value)
  Setting["channel.#{ key }"] = value if Setting["channel.#{ key }"].blank?
end

Constant.style.map do |key, value|
  Setting["style.#{ key }"] = value if Setting["style.#{ key }"].blank?
end
