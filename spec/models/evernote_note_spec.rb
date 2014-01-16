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

  it { should be_valid }
  it { should respond_to(:cloud_note_identifier) }
  it { should respond_to(:note_id) }
  it { should respond_to(:dirty) }
  it { should respond_to(:attempts) }
  it { should respond_to(:content_hash) }
  it { should respond_to(:update_sequence_number) }

  it { should respond_to(:dirtify) }
  it { should respond_to(:undirtify) }
  it { should respond_to(:max_out_attempts) }
  it { should respond_to(:increment_attempts) }

  it { should belong_to(:note) }

  its(:note) { should == note }

  it { should validate_presence_of(:cloud_note_identifier) }
  # it { should validate_presence_of(:note) }

  it { should validate_uniqueness_of(:note_id) }
  it { should validate_uniqueness_of(:cloud_note_identifier) }

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
    its(:dirty) { should == false }
    its(:attempts) { should == 0 }
  end

  describe '#increment_attempts increments attempts' do
    before do
      @evernote_note = FactoryGirl.create(:evernote_note, attempts: 0)
      @evernote_note.increment_attempts
    end
    its(:attempts) { should == 1 }
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
