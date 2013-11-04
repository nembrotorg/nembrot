class CloudNoteMailer < ActionMailer::Base
  default from: Settings.admin_email

  def syncdown_note_failed(provider, guid, title, username, error = 'failed')
    @provider = provider.titlecase
    @guid = guid
    @title = title
    @username = username

    mail(
      to: Settings.channel.monitoring_email,
      subject: I18n.t("notes.sync.#{ error }.email.subject", provider: @provider.titlecase, guid: @guid, title: @title, username: @username),
      host: Settings.host
    )
  end
end
