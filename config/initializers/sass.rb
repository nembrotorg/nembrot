# encoding: utf-8

module Sass::Script::Functions
  def settings_style(setting)
    assert_type setting, :String
    Sass::Script::Parser.parse(Setting["#{ setting.value }"].to_s, 0, 0)
  end
  declare :settings_style, args: [:setting]
end
