class CloudServiceMailer < ActionMailer::Base
  default from: Setting['advanced.admin_email']

  def auth_not_found(provider)
    @provider = provider.titlecase
    @url = "#{root_url}users/auth/#{ provider }"

    mail(
      to: Setting['advanced.admin_email'],
      subject: I18n.t('auth.email.subject', provider: provider.titlecase, url: @url),
      host: Constant.host
    )
  end
end
