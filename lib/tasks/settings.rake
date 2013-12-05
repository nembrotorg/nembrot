namespace :settings do

  desc 'Seed tasks'

  task update_defaults: :environment do |t, args|

    puts 'Updating default settings...'

    # First remove obsolete settings
    Setting.all.each do |key, value|
      puts "Deleting default: #{ key }"
      Setting.destroy key if Constant[key].nil? && !Setting[key].nil?
    end

    Constant.channel.map do |key, value|
      puts "Setting default: channel.#{ key }"
      Setting.save_default("channel.#{ key }", value) if Setting["channel.#{ key }"].blank?
    end

    Constant.advanced.map do |key, value|
      puts "Setting default: advanced.#{ key }"
      Setting.save_default("advanced.#{ key }", value) if Setting["advanced.#{ key }"].blank?
    end

    Constant.style.map do |key, value|
      puts "Setting default: style.#{ key }"
      Setting.save_default("style.#{ key }", value) if Setting["style.#{ key }"].blank?
    end

    puts 'Done.'
  end
end
