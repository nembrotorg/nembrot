ActionMailer::Base.smtp_settings = {
  address:              Secret.mailer.address,
  port:                 Secret.mailer.port,
  domain:               Secret.mailer.domain,
  user_name:            Secret.mailer.user_name,
  password:             Secret.mailer.password,
  authentication:       'plain',
  enable_starttls_auto: true
}

ActionMailer::Base.default_url_options[:host] = Constant.host
