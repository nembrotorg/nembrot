class PantographMailer < ActionMailer::Base
  default from: NB.admin_email

  def tweet_failed(message)
    @message = message

    mail(
      to: NB.monitoring_email,
      subject: message,
      host: NB.host
    )
  end
end
