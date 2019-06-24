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

# NB is used as an alias of Alias Figaro.env.
#  NB is not available in /initializers and neither NB nor Figaro.env are
#  settable, so ENV is used in /initializers and /spec.
NB = Figaro.env
