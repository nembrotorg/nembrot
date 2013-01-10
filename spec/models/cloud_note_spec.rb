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
  it { should respond_to(:sync_retries) }
  it { should respond_to(:content_hash) }

  it { should belong_to(:note) }
  it { should belong_to(:cloud_service) }

  its(:note) { should == note }
  its(:cloud_service) { should == cloud_service }

  it { should validate_presence_of(:cloud_note_identifier) }
  it { should validate_presence_of(:note) }
  it { should validate_presence_of(:cloud_service) }

  it { should validate_uniqueness_of(:cloud_note_identifier).scoped_to(:cloud_service_id) }

  describe "needs_syncdown scope should contain all dirty notes" do
    before {
      @cloud_note = FactoryGirl.create(:cloud_note, :dirty => true, :sync_retries => 0)
    }
    CloudNote.needs_syncdown.last.should == @cloud_note
  end

  describe "needs_syncdown scope should not contain dirty notes that have been retried too often" do
    before {
      @cloud_note = FactoryGirl.create(:cloud_note, :dirty => true, :sync_retries => Settings.notes.sync_retries + 1)
    }
    CloudNote.needs_syncdown.last.should == nil
  end
end
