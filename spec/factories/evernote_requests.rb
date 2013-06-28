FactoryGirl.define do
  factory :evernote_request do

    ignore do
#      evernote_note
      offline true
    end

    cloud_note_metadata OpenStruct.new({ 
      :title => 'Help!',
      :content => 'CCCC',
      :attributes => OpenStruct.new({ 
          :latitude => 1,
          :longitude => 2
        })
    })
    cloud_note_tags ['tag1', 'tag2']
    initialize_with { new(evernote_note) }
    initialize_with { new(offline) }
  end
end
