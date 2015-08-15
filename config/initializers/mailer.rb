ActionMailer::Base.smtp_settings = {
  address:              ENV['mailer_address'],
  port:                 ENV['mailer_port'],
  domain:               ENV['mailer_domain'],
  user_name:            ENV['mailer_user_name'],
  password:             ENV['mailer_password'],
  authentication:       'plain',
  enable_starttls_auto: true
}

ActionMailer::Base.default_url_options[:host] = ENV['host']
