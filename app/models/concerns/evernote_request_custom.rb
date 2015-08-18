# encoding: utf-8

module EvernoteRequestCustom
  extend ActiveSupport::Concern

  def required_evernote_notebooks
    NB.evernote_notebooks
  end
end
