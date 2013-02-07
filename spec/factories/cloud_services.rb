FactoryGirl.define do
	factory :cloud_service do
		sequence( :name ) { |n| "xABCDEF#{n}" }
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
