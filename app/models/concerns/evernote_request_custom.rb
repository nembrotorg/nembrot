# encoding: utf-8

module EvernoteRequestCustom
  extend ActiveSupport::Concern

  def required_evernote_notebooks
    Channel.pluck(:notebooks)
  end
end
