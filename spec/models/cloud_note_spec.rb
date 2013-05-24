describe CloudNote do

  let(:note) { FactoryGirl.build_stubbed(:note) }
  let(:cloud_service) { FactoryGirl.build_stubbed(:cloud_service) }
  before {
    @cloud_note = FactoryGirl.build_stubbed(:cloud_note, :note => note, :cloud_service => cloud_service)
  }

  subject { @cloud_note }

  it { should be_valid }
  it { should respond_to(:cloud_note_identifier) }
  it { should respond_to(:note_id) }
  it { should respond_to(:cloud_service_id) }
  it { should respond_to(:dirty) }
  it { should respond_to(:attempts) }
  it { should respond_to(:content_hash) }
  it { should respond_to(:update_sequence_number) }

  it { should belong_to(:note) }
  it { should belong_to(:cloud_service) }

  its(:note) { should == note }
  its(:cloud_service) { should == cloud_service }

  it { should validate_presence_of(:cloud_note_identifier) }
  # it { should validate_presence_of(:note) }
  it { should validate_presence_of(:cloud_service) }

  it { should validate_uniqueness_of(:cloud_note_identifier).scoped_to(:cloud_service_id) }

  describe "need_syncdown scope should contain all dirty notes" do
    before {
      @cloud_note = FactoryGirl.create(:cloud_note, :dirty => true, :attempts => 0)
    }
    CloudNote.need_syncdown.last.should == @cloud_note
  end

  describe "need_syncdown scope should increment attempts when requested to" do
    before {
      @cloud_note = FactoryGirl.create(:cloud_note, :attempts => 0)
      @cloud_note.increment_attempts
    }
    its(:attempts) { should == 1 }
  end

  describe "need_syncdown scope should not contain dirty notes that have been retried too often" do
    before {
      @cloud_note = FactoryGirl.create(:cloud_note, :dirty => true, :attempts => Settings.notes.attempts + 1)
    }
    CloudNote.need_syncdown.last.should == nil
  end

  describe "a cloud_note is disincluded from need_syncdown when max_out method is applied to it" do
    before {
      @cloud_note = FactoryGirl.create(:cloud_note, :dirty => true)
      @cloud_note.increment_attempts
      @cloud_note.max_out_attempts
    }
    CloudNote.need_syncdown.last.should == nil
  end

  describe "run_evernote_tasks should syncdown pending notes" do
    before {
    }
    it "should de-activate a note that is not in a required notebook" do
      # xxx
    end
    it "should de-activate a note that has been deleted in the cloud notebook" do
      # xxx
    end
    it "should de-activate a note not tagged with __PUBLISH (or synonyms)" do
      # xxx
    end
    it "should not update a note tagged with __IGNORE (or synonyms)" do
      # xxx
    end
    it "should not request full data if content hash has not changed" do
      # xxx
    end
    it "should request full data if content hash has changed" do
      # xxx
    end
    it "should syncdown resource if it has changed" do
      # xxx
    end
  end
end
