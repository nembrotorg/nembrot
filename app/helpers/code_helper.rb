# encoding: utf-8

module CodeHelper
  def model_file(controller)
    File.join('app', 'models', "#{ _singularize_controller(controller) }.rb")
  end

  def controller_file(controller)
    File.join('app', 'controllers', "#{ _pluralize_controller(controller) }_controller.rb")
  end

  def view_file(controller, action)
    action.gsub!(/.*show/, 'show')
    action = 'index' if controller == 'pantograph'
    File.join('app', 'views', "#{ _pluralize_controller(controller) }/#{ action }.html.slim")
  end

  def coderay(file)
    CodeRay.scan(File.read(File.join(Rails.root, file)), :ruby).html(:line_numbers => :table, :tab_width => 2)
  end

  def _normalize_controller(controller)
    controller.gsub!(/(feature|citation|link)/, 'notes')
    controller
  end

  def _singularize_controller(controller)
    _normalize_controller(controller).singularize
  end

  def _pluralize_controller(controller)
    controller = _normalize_controller(controller)
    return controller if controller.in? %w(home colophon)
    controller.pluralize
  end
end
