ActionMailer::Base.smtp_settings = {
  address:              Settings.mailer.address,
  port:                 Settings.mailer.port,
  domain:               Settings.mailer.domain,
  user_name:            Secret.mailer.user_name,
  password:             Secret.mailer.password,
  authentication:       'plain',
  enable_starttls_auto: true
}

ActionMailer::Base.default_url_options[:host] = Settings.host
