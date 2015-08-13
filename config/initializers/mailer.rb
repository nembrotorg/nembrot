ActionMailer::Base.smtp_settings = {
  address:              Figaro.env.mailer_address,
  port:                 Figaro.env.mailer_port,
  domain:               Figaro.env.mailer_domain,
  user_name:            Figaro.env.mailer_user_name,
  password:             Figaro.env.mailer_password,
  authentication:       'plain',
  enable_starttls_auto: true
}

ActionMailer::Base.default_url_options[:host] = Constant.host
