class PantographMailer < ActionMailer::Base
  default from: Constant.admin.email

  def tweet_failed(message)
    @message = message

    mail(
      to: Setting['advanced.monitoring_email'],
      subject: message,
      host: Constant.host
    )
  end
end
