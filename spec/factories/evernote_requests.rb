FactoryGirl.define do
  factory :evernote_request do
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
    cloud_note_data OpenStruct.new({
                                     content: 'Plain text.',
      created: 100.minutes.ago.to_time.to_i * 1000,
      updated: 10.minutes.ago.to_time.to_i * 1000
                                   })
    cloud_note_tags %w(__PUBLISH)
    evernote_note
  end
end
