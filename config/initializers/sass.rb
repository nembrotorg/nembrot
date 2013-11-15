# encoding: utf-8

module Sass::Script::Functions
  def settings_style(setting)
    assert_type setting, :String
    return_value = ActiveRecord::Base.connection.table_exists?('settings') ? Setting["#{ setting.value }"].to_s : Constant["#{ setting.value }"].to_s
    Sass::Script::Parser.parse(return_value, 0, 0)
  end
  declare :settings_style, args: [:setting]
end
