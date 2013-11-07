# See http://stackoverflow.com/questions/19841292

if ActiveRecord::Base.connection.table_exists? 'settings'

  Constant.channel.map do |key, value|
    # Try Namespaced defaults
    # Setting.save_default("channel.#{ key }", value)
    Setting["channel.#{ key }"] = value if Setting["channel.#{ key }"].blank?
  end

  Constant.style.map do |key, value|
    Setting["style.#{ key }"] = value if Setting["style.#{ key }"].blank?
  end

end
