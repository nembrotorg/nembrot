# encoding: utf-8

describe EvernoteNote do
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
  it { is_expected.to respond_to(:attempts) }
  it { is_expected.to respond_to(:content_hash) }
  it { is_expected.to respond_to(:update_sequence_number) }

  it { is_expected.to respond_to(:dirtify) }
  it { is_expected.to respond_to(:undirtify) }
  it { is_expected.to respond_to(:max_out_attempts) }
  it { is_expected.to respond_to(:increment_attempts) }

  it { is_expected.to belong_to(:note) }

  its(:note) { should == note }

  it { is_expected.to validate_presence_of(:cloud_note_identifier) }
  # it { should validate_presence_of(:note) }

  #it { is_expected.to validate_uniqueness_of(:note_id) }
  #it { is_expected.to validate_uniqueness_of(:cloud_note_identifier) }

  describe '#dirtify marks it dirty' do
    before { @evernote_note.dirtify }
    its(:dirty) { should == true }
    its(:attempts) { should == 0 }
  end

  describe '#undirtify marks it not dirty' do
    before do
      @evernote_note = FactoryGirl.create(:evernote_note, dirty: true, attempts: 1)
      @evernote_note.undirtify
    end
    its(:dirty) { is_expected.to eq(false) }
    its(:attempts) { is_expected.to eq(0) }
  end

  describe '#increment_attempts increments attempts' do
    before do
      @evernote_note = FactoryGirl.create(:evernote_note, attempts: 0)
      @evernote_note.increment_attempts
    end
    its(:attempts) { is_expected.to eq(1) }
  end

  describe '#max_out_attempts increments attempts' do
    before { @evernote_note.max_out_attempts }
    its(:attempts) { should >=  Setting['advanced.attempts'].to_i }
  end

  describe 'scope :need_syncdown contains all dirty notes' do
    before do
      @evernote_note = FactoryGirl.create(:evernote_note, dirty: true, attempts: 0)
    end
    EvernoteNote.need_syncdown.last.should == @evernote_note
  end

  describe 'scope :need_syncdown does not contain dirty notes retried too often' do
    before do
      @evernote_note = FactoryGirl.create(:evernote_note,
                                          dirty: true,
                                          attempts: Setting['advanced.attempts'].to_i + 1)
    end
    EvernoteNote.need_syncdown.last.should == nil
  end

  describe 'is disincluded from :need_syncdown after #max_out_attempts' do
    before do
      @evernote_note = FactoryGirl.create(:evernote_note, dirty: true)
      @evernote_note.increment_attempts
      @evernote_note.max_out_attempts
    end
    EvernoteNote.need_syncdown.last.should == nil
  end
end
