# encoding: utf-8

module NoteCustom
  extend ActiveSupport::Concern

  included do
    # FIXME: This breaks for new notes because note_id is not found (see Channel.channels_that_use_this_note)
    # after_save :update_channels_locale, if: :body_changed?
  end

  module ClassMethods
    def channelled(channel)
      joins(:evernote_notes).where(evernote_notes: { cloud_notebook_identifier: channel.notebooks })
    end
  end

  def update_channels_locale
    Channel.update_locales(self)
  end
end
