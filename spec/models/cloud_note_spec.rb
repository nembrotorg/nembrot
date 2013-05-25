# encoding: utf-8

describe CloudNote do
  let(:note) { FactoryGirl.build_stubbed(:note) }
  let(:cloud_service) { FactoryGirl.build_stubbed(:cloud_service) }
  before do
    @cloud_note = FactoryGirl.build_stubbed(
      :cloud_note,
      note: note,
      cloud_service: cloud_service)
  end

  subject { @cloud_note }

  it { should be_valid }
  it { should respond_to(:cloud_note_identifier) }
  it { should respond_to(:note_id) }
  it { should respond_to(:cloud_service_id) }
  it { should respond_to(:dirty) }
  it { should respond_to(:attempts) }
  it { should respond_to(:content_hash) }
  it { should respond_to(:update_sequence_number) }

  it { should respond_to(:dirtify) }
  it { should respond_to(:undirtify) }
  it { should respond_to(:max_out_attempts) }
  it { should respond_to(:increment_attempts) }

  it { should belong_to(:note) }
  it { should belong_to(:cloud_service) }

  its(:note) { should == note }
  its(:cloud_service) { should == cloud_service }

  it { should validate_presence_of(:cloud_note_identifier) }
  # it { should validate_presence_of(:note) }
  it { should validate_presence_of(:cloud_service) }

  it do
    should validate_uniqueness_of(:cloud_note_identifier)
                                  .scoped_to(:cloud_service_id)
  end

  describe 'dirtify should mark it dirty' do
    before { @cloud_note.dirtify }
    its(:dirty) { should == true }
    its(:attempts) { should == 0 }
  end

  describe 'undirtify should mark it not dirty' do
    before do
      @cloud_note = FactoryGirl.create(:cloud_note, dirty: true, attempts: 1)
      @cloud_note.undirtify
    end
    its(:dirty) { should == false }
    its(:attempts) { should == 0 }
  end

  describe 'increment_attempts should increment attempts' do
    before do
      @cloud_note = FactoryGirl.create(:cloud_note, attempts: 0)
      @cloud_note.increment_attempts
    end
    its(:attempts) { should == 1 }
  end

  describe 'max_out_attempts should increment attempts' do
    before { @cloud_note.max_out_attempts }
    its(:attempts) { should >=  Settings.notes.attempts }
  end

  describe 'need_syncdown should contain all dirty notes' do
    before do
      @cloud_note = FactoryGirl.create(:cloud_note, dirty: true, attempts: 0)
    end
    CloudNote.need_syncdown.last.should == @cloud_note
  end

  describe 'need_syncdown should not contain dirty notes retried too often' do
    before do
      @cloud_note = FactoryGirl.create(:cloud_note,
                                        dirty: true,
                                        attempts: Settings.notes.attempts + 1)
    end
    CloudNote.need_syncdown.last.should == nil
  end

  describe 'is disincluded from need_syncdown after max_out_attempts' do
    before do
      @cloud_note = FactoryGirl.create(:cloud_note, dirty: true)
      @cloud_note.increment_attempts
      @cloud_note.max_out_attempts
    end
    CloudNote.need_syncdown.last.should == nil
  end

  describe 'run_evernote_tasks should syncdown pending notes' do
    it 'should de-activate a note that is not in a required notebook' do
      pending 'Need to add this test.'
    end
    it 'should de-activate a note that has been deleted in the cloud' do
      pending 'Need to add this test.'
    end
    it 'should de-activate a note not tagged with __PUBLISH (or synonyms)' do
      pending 'Need to add this test.'
    end
    it 'should not update a note tagged with __IGNORE (or synonyms)' do
      pending 'Need to add this test.'
    end
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
