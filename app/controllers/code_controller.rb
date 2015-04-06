# encoding: utf-8

class CodeController < ApplicationController

  include CodeHelper

  def show
    controller = params[:controller_script]
    action = params[:action_script]

    @model_file = model_file(controller)
    @model_script = coderay(@model_file)

    @controller_file = controller_file(controller)
    @controller_script = coderay(@controller_file)

    @view_file = view_file(controller, action)
    @view_script = coderay(@view_file)

    render partial: 'show'
  rescue
    render partial: 'error'
  end
end
