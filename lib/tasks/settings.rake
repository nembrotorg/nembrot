namespace :settings do

  desc 'Seed tasks'

  task update_defaults: :environment do |t, args|

    puts 'Updating default settings...'

    # First remove obsolete settings
    Setting.all.each do |key, value|
      Setting.destroy key if Constant[key].nil? && !Setting[key].nil?
    end

    Constant.channel.map do |key, value|
      Setting.save_default("channel.#{ key }", value)
    end

    Constant.advanced.map do |key, value|
      Setting.save_default("advanced.#{ key }", value)
    end

    Constant.style.map do |key, value|
      Setting.save_default("style.#{ key }", value)
    end

    puts 'Done.'
  end
end
