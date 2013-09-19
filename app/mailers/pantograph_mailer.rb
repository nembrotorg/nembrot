class PantographMailer < ActionMailer::Base
  default from: Settings.admin.email

  def tweet_failed(message)
    @message = message

    mail(
      to: Settings.monitoring.email,
      subject: message,
      host: Settings.host
    )
  end
end
