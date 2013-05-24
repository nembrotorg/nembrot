module Sass::Script::Functions
  def settings(string, opts = {})
    assert_type string, :String
    Sass::Script::String.new(Settings.styling[string])
  end
  declare :settings, args: [:string]
end
