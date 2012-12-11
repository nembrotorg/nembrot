class CloudNoteMailer < ActionMailer::Base
  default from: Settings.admin.email

  def syncdown_note_failed(provider, guid, username, error)
    @provider = provider.titlecase
    @guid = guid
    @username = username
    @error = error

    mail( 
      :to => Settings.monitoring.email,
      :subject => I18n.t('notes.sync.failed.email.subject', :provider => @provider.titlecase, :guid => @guid, :username => @username)
    )
  end
end
