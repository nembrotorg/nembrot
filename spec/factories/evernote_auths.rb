FactoryGirl.define do
	factory :evernote_auth do
    auth OpenStruct.new({
                          extra: OpenStruct.new({
                                                  access_token: 
                                                    OpenStruct.new({
                                                                     params: {
                                                                       edam_noteStoreUrl: 'MOCK_URL',
                                                                       oauth_token: 'MOCK_TOKEN'
                                                                     }
                                                                   })
                                                })
                        })
	end
end
