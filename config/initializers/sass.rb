# encoding: utf-8

module Sass::Script::Functions
  def settings_styling(setting)
    assert_type setting, :String
    Sass::Script::Parser.parse(Settings.styling[setting.value].to_s, 0, 0)
  end
  declare :settings_styling, args: [:setting]
end
