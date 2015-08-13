required_keys = [
  'database_encryption_key',
  'devise_secret_key',
  'evernote_key',
  'evernote_secret',
  'evernote_username',
  'mailer_address',
  'mailer_domain',
  'mailer_password',
  'secret_key_base'
]

Figaro.require_keys(required_keys)
