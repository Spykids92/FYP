Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'mZSkTrQRC3UNVBk6prigZg','NZAqlzERDIZPMkIMNsDMs7CdEGTxxoMsELyfGcshr4'
  provider :facebook,'177239512473461','a171b5b5aab84ea9b29ddaeeebf4e7b2', :client_options => { :ssl => { :ca_file => "#{Rails.root}/config/ca-bundle.crt" }}
  provider :google_oauth2,'582155052254-l18iu4nvo77gujespk0pdchtc4hvr0io.apps.googleusercontent.com','FrliAtgUJgpynsVJ1FCBB7WH'
  provider :identity, on_failed_registration: lambda { |env| 
    IdentitiesController.action(:new).call(env)
    }
end