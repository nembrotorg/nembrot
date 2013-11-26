Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?

  provider :evernote,
    Secret.auth.evernote.key,
    Secret.auth.evernote.secret,
    client_options: {
      site: Constant.evernote_server
    }
end
