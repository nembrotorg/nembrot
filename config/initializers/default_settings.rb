# See http://stackoverflow.com/questions/19841292

if ActiveRecord::Base.connection.table_exists? 'settings'

  # First remove obsolete settings
  Setting.all.each do |key, value|
    Setting.destroy key if Constant[key].nil? && !Setting[key].nil?
  end

  Constant.channel.map do |key, value|
    Setting.save_default("channel.#{ key }", value) if Setting["channel.#{ key }"].blank?
  end

  Constant.advanced.map do |key, value|
    Setting.save_default("advanced.#{ key }", value) if Setting["advanced.#{ key }"].blank?
  end

  Constant.style.map do |key, value|
    Setting.save_default("style.#{ key }", value) if Setting["style.#{ key }"].blank?
  end

end
