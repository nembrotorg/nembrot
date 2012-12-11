Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :evernote, 
    Secret.auth.evernote.consumer_key, 
    Secret.auth.evernote.consumer_secret, 
    :client_options => { 
      :site => Settings.evernote.server 
    }
end
