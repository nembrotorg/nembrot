describe Resource do

  let(:note) { FactoryGirl.build_stubbed(:note) }
  before {
    @resource = FactoryGirl.build_stubbed(:resource, :note => note)
  }

  subject { @resource }

  it { should belong_to(:note) }

  its(:note) { should == note }

  it { should be_valid }
  it { should respond_to(:cloud_resource_identifier) }
  it { should respond_to(:note_id) }
  it { should respond_to(:mime) }
  it { should respond_to(:caption) }
  it { should respond_to(:description) }
  it { should respond_to(:credit) }
  it { should respond_to(:source_url) }
  it { should respond_to(:external_updated_at) }
  it { should respond_to(:latitude) }
  it { should respond_to(:longitude) }
  it { should respond_to(:altitude) }
  it { should respond_to(:camera_make) }
  it { should respond_to(:camera_model) }
  it { should respond_to(:file_name) }
  it { should respond_to(:attachment) }
  it { should respond_to(:data_hash) }
  it { should respond_to(:width) }
  it { should respond_to(:height) }
  it { should respond_to(:size) }
  it { should respond_to(:dirty) }
  it { should respond_to(:sync_retries) }

  it { should validate_presence_of(:note) }
  it { should validate_presence_of(:cloud_resource_identifier) }
  it { should validate_uniqueness_of(:cloud_resource_identifier) }

  describe "needs_syncdown scope should contain all dirty resources" do
    before {
      @resource = FactoryGirl.build_stubbed(:resource, :dirty => true, :sync_retries => 0)
    }
    Resource.needs_syncdown.last.should == @resource
  end

  describe "needs_syncdown scope should not contain dirty resources that have been retried too often" do
    before {
      @resource = FactoryGirl.build_stubbed(:resource, :dirty => true, :sync_retries => Settings.notes.sync_retries + 1)
    }
    Resource.needs_syncdown.last.should == nil
  end
end
