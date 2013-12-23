Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'mZSkTrQRC3UNVBk6prigZg','NZAqlzERDIZPMkIMNsDMs7CdEGTxxoMsELyfGcshr4'
  provider :facebook,'177239512473461','a171b5b5aab84ea9b29ddaeeebf4e7b2', :client_options => { :ssl => { :ca_file => "#{Rails.root}/config/ca-bundle.crt" }}
  provider :google_oauth2,'582155052254.apps.googleusercontent.com','y31K4Dw6kZuH5F9uLC7l6A07'
  provider :identity, on_failed_registration: lambda { |env| 
    IdentitiesController.action(:new).call(env)
    }
end