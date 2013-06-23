FactoryGirl.define do
	factory :evernote_auth do
    auth OpenStruct.new({ 
        :extra => OpenStruct.new({ 
          :access_token =>
            OpenStruct.new({
              :params => {
                :edam_noteStoreUrl => "MOCK_URL",
                :oauth_token => "MOCK_TOKEN"
              }
            })
        }),
        :info => OpenStruct.new({ 
          :nickname => "MOCK_NICKNAME"
        })
      })
	end
end
