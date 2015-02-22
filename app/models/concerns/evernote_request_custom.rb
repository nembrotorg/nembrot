# encoding: utf-8

module EvernoteRequestCustom
  extend ActiveSupport::Concern

  def required_evernote_notebooks
    Settings['channel.evernote_notebooks']
  end
end
