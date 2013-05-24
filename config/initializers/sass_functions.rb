module Sass::Script::Functions
  def styling_setting(string, opts = {} )
    assert_type string, :String
    Sass::Script::String.new( Settings.styling[string] )
  end
  declare :styling_setting, :args => [:string]
end
