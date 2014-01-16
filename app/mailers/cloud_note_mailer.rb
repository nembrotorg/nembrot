class CloudNoteMailer < ActionMailer::Base
  default from: Setting['advanced.admin_email']

  def syncdown_note_failed(provider, guid, title, username, error = 'failed')
    @provider = provider.titlecase
    @guid = guid
    @title = title
    @username = username

    mail(
      to: Setting['advanced.admin_email'],
      subject: I18n.t("notes.sync.#{ error }.email.subject", provider: @provider.titlecase, guid: @guid, title: @title, username: @username),
      host: Constant.host
    )
  end
end
