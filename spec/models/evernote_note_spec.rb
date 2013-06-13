# encoding: utf-8

describe EvernoteNote do

  before do
    VCR.use_cassette('model/evernote_note_metadata') do
      EvernoteNote.add_task('e669c090-d8b2-4324-9eae-56bd31c64af7')
      @evernote_note = CloudNote.find_by_cloud_note_identifier('e669c090-d8b2-4324-9eae-56bd31c64af7')
      @evernote_note.syncdown_one
    end
  end

  subject { @evernote_note.note }

  its (:title) { should == 'The Man Without Qualities' }

end
