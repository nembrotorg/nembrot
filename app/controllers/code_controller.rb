# encoding: utf-8

class CodeController < ApplicationController
  def show
    @controller = params[:controller_script]
    @action = params[:action_script]
    render partial: 'show'
  rescue
    render partial: 'error'
  end
end
