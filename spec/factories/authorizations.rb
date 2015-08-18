FactoryGirl.define do
	factory :authorization do
    name 'First Last'
    nickname 'MOCK_NICKNAME'
    email 'first.last@example.com'
    provider 'evernote'
    extra OpenStruct.new({
                           access_token:
                             OpenStruct.new({
                                              params: {
                                                edam_noteStoreUrl: 'MOCK_URL',
                                                oauth_token: 'MOCK_TOKEN'
                                              },
                               consumer: {
                                 key: ENV['evernote_key'],
                                 secret: ENV['evernote_secret']
                               }
                            })
                         })
	end
end
