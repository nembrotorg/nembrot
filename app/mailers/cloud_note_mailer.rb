class CloudNoteMailer < ActionMailer::Base
  default from: Settings.admin.email

  def syncdown_note_failed(provider, guid, title, username, error = 'failed')
    @provider = provider.titlecase
    @guid = guid
    @title = title
    @username = username

    mail(
      to: Settings.monitoring.email,
      subject: I18n.t("notes.sync.#{ error }.email.subject", provider: @provider.titlecase, guid: @guid, title: @title, username: @username),
      host: Settings.host
    )
  end
end
