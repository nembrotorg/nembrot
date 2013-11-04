class CloudServiceMailer < ActionMailer::Base
  default from: Settings.admin_email

  def auth_not_found(provider)
    @provider = provider.titlecase
    @url = "#{root_url}auth/#{ provider }"

    mail(
      :to => Settings.channel.monitoring_email,
      :subject => I18n.t('auth.email.subject', :provider => provider.titlecase, :url => @url),
      :host => Settings.host
    )
  end
end
