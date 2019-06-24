# encoding: utf-8

RSpec.describe EvernoteNote do
  let(:note) { FactoryGirl.build_stubbed(:note) }
  let(:evernote_auth) { FactoryGirl.build_stubbed(:evernote_auth) }
  before do
    @evernote_note = FactoryGirl.build_stubbed(
      :evernote_note,
      note: note)
  end

  subject { @evernote_note }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to(:cloud_note_identifier) }
  it { is_expected.to respond_to(:note_id) }
  it { is_expected.to respond_to(:dirty) }
  it { is_expected.to respond_to(:content_hash) }
  it { is_expected.to respond_to(:update_sequence_number) }

  it { is_expected.to respond_to(:dirtify) }
  it { is_expected.to respond_to(:undirtify) }

  it { is_expected.to belong_to(:note) }

  its(:note) { should == note }

  it { is_expected.to validate_presence_of(:cloud_note_identifier) }
  # it { should validate_presence_of(:note) }

  #it { is_expected.to validate_uniqueness_of(:note_id) }
  #it { is_expected.to validate_uniqueness_of(:cloud_note_identifier) }

  describe '#dirtify marks it dirty' do
    before { @evernote_note.dirtify }
    its(:dirty) { should == true }
  end

  describe '#undirtify marks it not dirty' do
    before do
      @evernote_note = FactoryGirl.create(:evernote_note)
      @evernote_note.undirtify
    end
    its(:dirty) { is_expected.to eq(false) }
  end

  describe '#add_task' do
    before { ENV['evernote_notebooks'] = 'MYNOTEBOOK,OTHERNOTEBOOK' }
    context 'when note is in required notebook' do
      it 'adds a job' do
        expect(SyncNoteJob).to receive(:perform_later).once
        EvernoteNote.add_task('MYNOTE', 'MYNOTEBOOK')
      end
    end
    context 'when note is not in required notebook' do
      it 'adds a job' do
        expect(SyncNoteJob).to_not receive(:perform_later)
        EvernoteNote.add_task('MYNOTE', 'NOTMYNOTEBOOK')
      end
    end
  end
end
