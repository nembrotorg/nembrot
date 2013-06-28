describe EvernoteNote do
  let(:evernote_note) { FactoryGirl.build_stubbed(:evernote_note) }
  before do    
    @evernote_request = FactoryGirl.build_stubbed(:evernote_request, :evernote_note => evernote_note)
  end

  subject { @evernote_request }

  pending "its (:cloud_note_identifier) { should == 'x' }"
end
