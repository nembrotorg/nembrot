FactoryGirl.define do
  factory :evernote_request do

    ignore do
#      evernote_note evernote_note
      cloud_note_metadata OpenStruct.new({
        title: 'Evernote title!',
        content: 'Evernote content.',
        attributes: OpenStruct.new({
            latitude: 1,
            longitude: 2
          })
        })
      cloud_note_tags %w(tag1 tag2)
    end

    initialize_with { new(evernote_note) }
  end
end
