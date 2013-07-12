FactoryGirl.define do
  factory :evernote_request do
    evernote_auth OpenStruct.new({
      oauth_token: 'OAUTH_TOKEN',
      note_store: 'NOTE_STORE',
      nickname: 'USER_NICKNAME'
    })
    cloud_note_metadata OpenStruct.new({
      active: true,
      guid: 'NOTE_GUID',
      notebookGuid: 'NOTEBOOK_GUID',
      title: 'Evernote title',
      content: 'Evernote content.',
      nickname: 'Bob',
      attributes: OpenStruct.new({
          latitude: 1,
          longitude: 2
        })
      })
    cloud_note_tags %w(__PUBLISH)
  end
end
