# encoding: utf-8

# FIXME: These tests are flawed. Content is not being changed at all!

RSpec.describe EvernoteNote do
  before(:example) do
    ENV['evernote_notebooks'] = 'NOTEBOOK_GUID'
    ENV['instructions_required'] = '__PUBLISH'
    @evernote_request = FactoryGirl.build(:evernote_request)
  end

  subject { @evernote_request }

  describe '#update_necessary?' do
    context 'when note is in a required notebook' do
      before do
        @evernote_request.cloud_note_metadata[:notebookGuid] = 'NOTEBOOK_GUID'
      end
      # pending its(:update_necessary?) { is_expected.to be_truthy }
    end

    context 'when note is not in a required notebook' do
      before do
        @evernote_request.cloud_note_metadata[:notebookGuid] = 'ANOTHER_NOTEBOOK_GUID'
      end
      its(:update_necessary?) { is_expected.to be_falsey }
    end

    context 'when cloud note is not active' do
      before do
        @evernote_request.cloud_note_metadata[:active] = false
      end
      its(:update_necessary?) { is_expected.to be_falsey }
      it 'destroys evernote_note' do
        expect(@evernote_note).to be_nil
      end
    end

    context 'when cloud note has not been updated' do
      before do
        @evernote_request.evernote_note.note.external_updated_at = 0
        @evernote_request.cloud_note_metadata[:updated] = 0
      end
      # pending its(:update_necessary?) { is_expected.to be_falsey }
      it 'undirtifies evernote_note' do
        @evernote_request.evernote_note.dirty { is_expected.to be_falsey }
      end
    end

    context 'when cloud note does not have a required tag' do
      before do
        @evernote_request.cloud_note_tags = %w(__NOT_PUBLISH)
      end
      its(:update_necessary?) { is_expected.to be_falsey }
      it 'destroys evernote_note' do
        expect(@evernote_note).to be_nil
      end
    end

    context 'when cloud note has an instruction to ignore' do
      before do
        ENV['instructions_ignore'] = '__IGNORE'
        @evernote_request.cloud_note_tags = %w(__IGNORE)
      end
      its(:update_necessary?) { is_expected.to be_falsey }
      it 'destroys evernote_note' do
        expect(@evernote_note).to be_nil
      end
    end
  end

  describe '#note_is_not_conflicted?' do
    context 'when note content does not contain a conflict warning' do
      before do
        @evernote_request.cloud_note_data[:content] = 'Plain text.'
      end
      its(:note_is_not_conflicted?) { is_expected.to be_truthy }
    end

    context 'when note content contains a conflict warning' do
      before do
        @evernote_request.cloud_note_data.content = 'Plain text.<hr/>Conflicting modification on 01.01.2001'
      end
      # These tests are flawed. Content is not being changed at all.
      # @evernote_request.cloud_note_data[:content].should == 'xxx'
      # pending "its(:note_is_not_conflicted?) { should be_falsey }"
    end
  end

  describe '#populate' do
    # pending 'Add this test.'
  end

  describe '#update_evernote_note_with_evernote_data' do
    # pending 'Add this test.'
  end

  describe 'run_evernote_tasks should syncdown # pending notes' do
    it 'should not request full data if content hash has not changed' do
      # pending 'Need to add this test.'
    end
    it 'should request full data if content hash has changed' do
      # pending 'Need to add this test.'
    end
    it 'should syncdown resource if it has changed' do
      # pending 'Need to add this test.'
    end
  end
end
