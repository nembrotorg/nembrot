# encoding: utf-8

module CodeHelper
  def model_file(controller)
    controller.gsub!(/(feature|citation|clipping)/, 'notes')
    File.join('app', 'models', "#{ controller.singularize }.rb")
  end

  def controller_file(controller)
    File.join('app', 'controllers', "#{ controller.pluralize }_controller.rb")
  end

  def view_file(controller, action)
    controller.gsub!(/(feature|citation|clipping)/, 'notes')
    action.gsub!(/.*show/, 'show')
    action = 'index' if controller == 'pantograph'
    File.join('app', 'views', "#{ controller.pluralize }/#{ action }.html.slim")
  end

  def coderay(file)
    CodeRay.scan(File.read(File.join(Rails.root, file)), :ruby).html(:line_numbers => :table, :tab_width => 2)
  end
end
