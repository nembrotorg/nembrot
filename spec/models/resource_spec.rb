# encoding: utf-8

describe Resource do
  let(:note) { FactoryGirl.create(:note) }
  before { @resource = FactoryGirl.create(:resource, note: note) }
  subject { @resource }

  it { should belong_to(:note) }

  its(:note) { should == note }

  it { should be_valid }
  it { should respond_to(:altitude) }
  it { should respond_to(:attachment) }
  it { should respond_to(:attempts) }
  it { should respond_to(:blank_location) }
  it { should respond_to(:camera_make) }
  it { should respond_to(:camera_model) }
  it { should respond_to(:caption) }
  it { should respond_to(:cloud_resource_identifier) }
  it { should respond_to(:credit) }
  it { should respond_to(:cut_location) }
  it { should respond_to(:data_hash) }
  it { should respond_to(:description) }
  it { should respond_to(:dirtify) }
  it { should respond_to(:dirty) }
  it { should respond_to(:external_updated_at) }
  it { should respond_to(:file_name) }
  it { should respond_to(:height) }
  it { should respond_to(:increment_attempts) }
  it { should respond_to(:latitude) }
  it { should respond_to(:local_file_name) }
  it { should respond_to(:longitude) }
  it { should respond_to(:max_out_attempts) }
  it { should respond_to(:mime) }
  it { should respond_to(:note_id) }
  it { should respond_to(:raw_location) }
  it { should respond_to(:size) }
  it { should respond_to(:source_url) }
  it { should respond_to(:template_location) }
  it { should respond_to(:undirtify) }
  it { should respond_to(:width) }

  it { should validate_presence_of(:note) }
  it { should validate_presence_of(:cloud_resource_identifier) }
  it { should validate_uniqueness_of(:cloud_resource_identifier) }

  describe ':need_syncdown' do
    before { @resource.update_attributes(dirty: true, attempts: 0, try_again_at: 1.minute.ago) }
    it 'contains all dirty resources' do
      Resource.need_syncdown.last.should == @resource
    end

    context 'when resources are maxed_out or dirty' do
      before { @resource.update_attributes(dirty: true, attempts: Setting['advanced.attempts'].to_i + 1, try_again_at: 1.minute.ago) }
      Resource.need_syncdown.last.should == nil
    end
  end

  describe '#dirtify' do
    before { @resource.dirtify }
    its(:dirty) { should == true }
    its(:attempts) { should == 0 }
  end

  describe '#undirtify' do
    before do
      @resource = FactoryGirl.create(:resource, dirty: true, attempts: 1)
      @resource.undirtify
    end
    its(:dirty) { should == false }
    its(:attempts) { should == 0 }
  end

  describe '#increment_attempts' do
    before do
      @resource = FactoryGirl.create(:resource, attempts: 0)
      @resource.increment_attempts
    end
    its(:attempts) { should == 1 }
  end

  describe '#max_out_attempts' do
    before { @resource.max_out_attempts }
    its(:attempts) { should >=  Setting['advanced.attempts'].to_i }
  end

  describe '#file_ext' do
    before { @resource.update_attributes(mime: 'image/png') }
    its(:file_ext) { should == 'png' }
  end

  describe '#raw_location' do
    its(:raw_location) { should == File.join(Rails.root, 'public', 'resources', 'raw', "#{ @resource.id }.png") }
  end

  describe '#template_location' do
    @resource2 = FactoryGirl.build_stubbed(:resource, mime: 'png')
    @resource2.template_location(16, 9) do
      should == File.join(Rails.root, 'public', 'resources', 'templates', '1-16-9.png')
    end
  end

  describe '#cut_location' do
    @resource2 = FactoryGirl.build_stubbed(:resource, mime: 'png')
    @resource2.cut_location(160, 90, 500, 1, 2, 3) do
      should == File.join(Rails.root, 'public', 'resources', 'cut', 'image-caption-160-90-500-1-2-3.png')
    end
  end

  describe '#blank_location' do
    before { @resource.update_attributes(mime: 'image/png') }
    its(:blank_location) { should == File.join(Rails.root, 'public', 'resources', 'cut', 'blank.png') }
  end

  describe '#local_file_name' do
    context 'when mime type is not image and file_name is available' do
      before { @resource.update_attributes(mime: 'application/pdf', file_name: 'ORIGINAL FILE NAME') }
      its(:local_file_name) { should == 'original-file-name' }
    end

    context 'when mime type is image and caption is available' do
      before { @resource.update_attributes(caption: 'IMAGE CAPTION') }
      its(:local_file_name) { should == 'image-caption' }
    end

    context 'when mime type is image, caption is nil and a description exists' do
      before { @resource.update_attributes(caption: nil, description: 'IMAGE DESCRIPTION') }
      its(:local_file_name) { should == 'image-description' }
    end

    context 'when mime type is image, cap. and description are nil, and file_name exists' do
      before { @resource.update_attributes(caption: nil, description: nil, file_name: 'ORIGINAL FILE NAME') }
      its(:local_file_name) { should == 'original-file-name' }
    end

    context 'when caption is not in Latin script' do
      before { @resource.update_attributes(caption: 'نين السياسة', description: nil, file_name: 'ORIGINAL FILE NAME') }
      its(:local_file_name) { should == 'original-file-name' }
    end

    context 'when mime type is image, file_name is empty and all else is nil' do
      before { @resource.update_attributes(caption: nil, description: nil, file_name: '') }
      its(:local_file_name) { should == @resource.cloud_resource_identifier.parameterize }
    end

    describe 'when mime type is image and all else is nil' do
      before do
        @resource.update_attributes(caption: nil, description: nil, file_name: '')
        @resource.valid?
      end
      its(:local_file_name) { should == @resource.cloud_resource_identifier.parameterize }
    end
  end

  pending '#delete_binaries'
end
