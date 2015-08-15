class CloudServiceMailer < ActionMailer::Base
  default from: NB.admin_email

  def auth_not_found(provider)
    @provider = provider.titlecase
    @url = "#{root_url}users/auth/#{ provider }"

    mail(
      to: NB.admin_email,
      subject: I18n.t('auth.email.subject', provider: provider.titlecase, url: @url),
      host: NB.host
    )
  end
end
