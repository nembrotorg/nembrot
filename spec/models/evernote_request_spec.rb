# encoding: utf-8

describe EvernoteNote do

  before do
    Settings.evernote['notebooks'] = %w(NOTEBOOK_GUID)
    Settings.notes['instructions']['required'] = %w(__PUBLISH)
    @note = FactoryGirl.build(:note)
    @evernote_note = FactoryGirl.build(:evernote_note, note: @note)
    @evernote_request = FactoryGirl.build(:evernote_request, evernote_note: @evernote_note)
    @evernote_request.cloud_note_metadata['guid'] = @evernote_note.cloud_note_identifier
  end

  subject { @evernote_request }

  describe '#update_necessary?' do

    context 'when note is in a required notebook' do
      before do
        @evernote_request.cloud_note_metadata['notebookGuid'] = 'NOTEBOOK_GUID'
      end
      its(:update_necessary?) { should be_true }
    end

    context 'when note is not in a required notebook' do
      before do
        @evernote_request.cloud_note_metadata['notebookGuid'] = 'ANOTHER_NOTEBOOK_GUID'
      end
      its(:update_necessary?) { should be_false }
    end

    context 'when cloud note is not active' do
      before do
        @evernote_request.cloud_note_metadata['active'] = false
      end
      its(:update_necessary?) { should be_false }
      it 'destroys evernote_note' do
        pending "@evernote_note.should == nil"
      end
    end

    context 'when cloud note has not been updated' do
      before do
        @note.external_updated_at = 0
        @evernote_request.cloud_note_metadata['updated'] = 0
      end
      its(:update_necessary?) { should be_false }
      it 'undirtifies evernote_note' do
        @evernote_note.dirty == false
        @evernote_note.attempts == 0
      end
    end

    context 'when cloud note does not have a required tag' do
      before do
        @evernote_request.cloud_note_tags = %w(__NOT_PUBLISH)
      end
      its(:update_necessary?) { should be_false }
      it 'destroys evernote_note' do
        pending "@evernote_note.should == nil"
      end
    end

    context 'when cloud note has an instruction to ignore' do
      before do
        Settings.notes['instructions']['ignore'] = %w(__IGNORE)
        @evernote_request.cloud_note_tags = %w(__IGNORE)
      end
      its(:update_necessary?) { should be_false }
      it 'destroys evernote_note' do
        pending "@evernote_note.should == nil"
      end
    end
  end

  describe '#calculate_updated_at' do
    pending 'Add this test.'
  end

  describe '#populate' do
    pending 'Add this test.'
  end

  describe '#update_evernote_note_with_evernote_data' do
    pending 'Add this test.'
  end

  describe 'run_evernote_tasks should syncdown pending notes' do
    it 'should not request full data if content hash has not changed' do
      pending 'Need to add this test.'
    end
    it 'should request full data if content hash has changed' do
      pending 'Need to add this test.'
    end
    it 'should syncdown resource if it has changed' do
      pending 'Need to add this test.'
    end
  end
end
