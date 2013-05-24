describe Resource do
  let(:note) { FactoryGirl.create(:note) }
  before { @resource = FactoryGirl.create(:resource, note: note) }
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
  it { should respond_to(:local_file_name) }
  it { should respond_to(:attachment) }
  it { should respond_to(:data_hash) }
  it { should respond_to(:width) }
  it { should respond_to(:height) }
  it { should respond_to(:size) }
  it { should respond_to(:dirty) }
  it { should respond_to(:attempts) }

  it { should validate_presence_of(:note) }
  it { should validate_presence_of(:cloud_resource_identifier) }
  it { should validate_uniqueness_of(:cloud_resource_identifier) }

  describe 'file_ext should return correct file extension' do
    before { @resource.update_attributes(mime: 'image/png') }
    its(:file_ext) { should == 'png' }
  end

  describe 'blank_location should return path for blank file of same format' do
    before { @resource.update_attributes(mime: 'image/png') }
    its(:blank_location) { should == File.join(Rails.root, 'public', 'resources', 'cut', 'blank.png') }
  end

  describe 'cut_location should return path to the cut image' do
    pending 'Need to add this test'
    before { @resource.update_attributes(caption: 'IMAGE CAPTION') }
    # its.cut_location(160, 90, 500, 0, 0, 0).should =~ /\/public\/resources\/cut\/image-caption-160-90-500-0-0-0.png/
  end

  describe 'template_location should return path to the cut image' do
    pending 'Need to add this test'
    # before {
    #  @resource = FactoryGirl.create(:resource, :note => note, :mime => 'image/png', :caption => 'IMAGE CAPTION')
    # }
    # @resource.cut_location(160, 90, 500, 0, 0, 0).should =~ /\/public\/resources\/cut\/image-caption-160-90-500-0-0-0.png/
    # @resource.template_location(16, 9).should =~ /\/public\/resources\/templates\/#{ @resource.cloud_resource_identifier }-16-9.png/
  end

  describe 'need_syncdown scope should contain all dirty resources' do
    before { @resource.update_attributes(dirty: true, attempts: 0) }
    Resource.need_syncdown.last.should == @resource
  end

  describe 'needs_syncdown scope should not contain dirty resources that have been retried too often' do
    before { @resource.update_attributes(dirty: true, attempts: Settings.notes.attempts + 1) }
    Resource.need_syncdown.last.should == nil
  end

  describe 'local_file_name is set to file_name if mime type is not image and file_name is available' do
    before { @resource.update_attributes(mime: 'application/pdf', file_name: 'ORIGINAL FILE NAME') }
    its(:local_file_name) { should == 'original-file-name' }
  end

  describe 'local_file_name is set to caption if mime type is image and caption is available' do
    before { @resource.update_attributes(caption: 'IMAGE CAPTION') }
    its(:local_file_name) { should == 'image-caption' }
  end

  describe 'local_file_name is set to description if mime type is image, caption is nil and description is available' do
    before { @resource.update_attributes(caption: nil, description: nil, file_name: 'IMAGE DESCRIPTION') }
    its(:local_file_name) { should == 'image-description' }
  end

  describe 'local_file_name is set to file_name if mime type is image, caption is nil, description is nil, and file_name is available' do
    before { @resource.update_attributes(caption: nil, description: nil, file_name: 'ORIGINAL FILE NAME') }
    its(:local_file_name) { should == 'original-file-name' }
  end

  describe 'local_file_name is set to cloud_resource_identifier if mime type is image, file_name is empty and all else is nil' do
    before { @resource.update_attributes(caption: nil, description: nil, file_name: '') }
    its(:local_file_name) { should == @resource.cloud_resource_identifier.parameterize }
  end

  describe 'local_file_name is set to cloud_resource_identifier if mime type is image and all else is nil' do
    before { 
      @resource.update_attributes(caption: nil, description: nil, file_name: '')
      @resource.valid?
    }
    its(:local_file_name) { should == @resource.cloud_resource_identifier.parameterize }
  end
end
