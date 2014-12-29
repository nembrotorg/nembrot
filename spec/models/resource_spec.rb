# encoding: utf-8

describe Resource do
  let(:note) { FactoryGirl.create(:note) }
  before { @resource = FactoryGirl.create(:resource, note: note) }
  subject { @resource }

  it { is_expected.to belong_to(:note) }

  its(:note) { is_expected.to eq(note) }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to(:altitude) }
  it { is_expected.to respond_to(:attachment) }
  it { is_expected.to respond_to(:attempts) }
  it { is_expected.to respond_to(:blank_location) }
  it { is_expected.to respond_to(:camera_make) }
  it { is_expected.to respond_to(:camera_model) }
  it { is_expected.to respond_to(:caption) }
  it { is_expected.to respond_to(:cloud_resource_identifier) }
  it { is_expected.to respond_to(:credit) }
  it { is_expected.to respond_to(:cut_location) }
  it { is_expected.to respond_to(:data_hash) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:dirtify) }
  it { is_expected.to respond_to(:dirty) }
  it { is_expected.to respond_to(:external_updated_at) }
  it { is_expected.to respond_to(:file_name) }
  it { is_expected.to respond_to(:height) }
  it { is_expected.to respond_to(:increment_attempts) }
  it { is_expected.to respond_to(:latitude) }
  it { is_expected.to respond_to(:local_file_name) }
  it { is_expected.to respond_to(:longitude) }
  it { is_expected.to respond_to(:max_out_attempts) }
  it { is_expected.to respond_to(:mime) }
  it { is_expected.to respond_to(:note_id) }
  it { is_expected.to respond_to(:raw_location) }
  it { is_expected.to respond_to(:size) }
  it { is_expected.to respond_to(:source_url) }
  it { is_expected.to respond_to(:template_location) }
  it { is_expected.to respond_to(:undirtify) }
  it { is_expected.to respond_to(:width) }

  it { is_expected.to validate_presence_of(:note) }
  it { is_expected.to validate_presence_of(:cloud_resource_identifier) }
  it { is_expected.to validate_uniqueness_of(:cloud_resource_identifier).scoped_to(:note_id) }

  describe ':need_syncdown' do
    before { @resource.update_attributes(dirty: true, attempts: 0, try_again_at: 1.minute.ago) }
    it 'contains all dirty resources' do
      expect(Resource.need_syncdown.last).to eq(@resource)
    end

    context 'when resources are maxed_out or dirty' do
      before { @resource.update_attributes(dirty: true, attempts: Setting['advanced.attempts'].to_i + 1, try_again_at: 1.minute.ago) }
      Resource.need_syncdown.last.should == nil
    end
  end

  describe ':attached_images' do
    before { @resource.update_attributes(width: Setting['style.images_min_width'].to_i + 1) }
    it 'contains resources larger than half the standard width' do
      expect(Resource.attached_images.last).to eq(@resource)
    end

    context 'does not contain resources smaller than half the standard width' do
      before { @resource.update_attributes(width: Setting['style.images_min_width'].to_i - 1) }
      Resource.attached_images.last.should == nil
    end
  end

  describe '#dirtify' do
    before { @resource.dirtify }
    its(:dirty) { is_expected.to eq(true) }
    its(:attempts) { is_expected.to eq(0) }
  end

  describe '#undirtify' do
    before do
      @resource = FactoryGirl.create(:resource, dirty: true, attempts: 1)
      @resource.undirtify
    end
    its(:dirty) { is_expected.to eq(false) }
    its(:attempts) { is_expected.to eq(0) }
  end

  describe '#increment_attempts' do
    before do
      @resource = FactoryGirl.create(:resource, attempts: 0)
      @resource.increment_attempts
    end
    its(:attempts) { is_expected.to eq(1) }
  end

  describe '#max_out_attempts' do
    before { @resource.max_out_attempts }
    its(:attempts) { is_expected.to be >=  Setting['advanced.attempts'].to_i }
  end

  describe '#file_ext' do
    before { @resource.update_attributes(mime: 'image/png') }
    its(:file_ext) { is_expected.to eq('png') }
  end

  describe '#raw_location' do
    its(:raw_location) { is_expected.to eq(File.join(Rails.root, 'public', 'resources', 'raw', "#{ @resource.id }.png")) }
  end

  describe '#template_location' do
    @resource2 = FactoryGirl.build_stubbed(:resource, mime: 'png')
    @resource2.template_location(16, 9) do
      is_expected.to eq(File.join(Rails.root, 'public', 'resources', 'templates', '1-16-9.png'))
    end
  end

  describe '#cut_location' do
    @resource2 = FactoryGirl.build_stubbed(:resource, mime: 'png')
    @resource2.cut_location(160, 90, 500, 1, 2, 3) do
      is_expected.to eq(File.join(Rails.root, 'public', 'resources', 'cut', 'image-caption-160-90-500-1-2-3.png'))
    end
  end

  describe '#blank_location' do
    before { @resource.update_attributes(mime: 'image/png') }
    its(:blank_location) { is_expected.to eq(File.join(Rails.root, 'public', 'resources', 'cut', 'blank.png')) }
  end

  describe '#local_file_name' do
    context 'when mime type is not image and file_name is available' do
      before { @resource.update_attributes(mime: 'application/pdf', file_name: 'ORIGINAL FILE NAME') }
      its(:local_file_name) { is_expected.to eq('original-file-name') }
    end

    context 'when mime type is image and caption is available' do
      before { @resource.update_attributes(caption: 'IMAGE CAPTION') }
      its(:local_file_name) { is_expected.to eq('image-caption') }
    end

    context 'when mime type is image, caption is nil and a description exists' do
      before { @resource.update_attributes(caption: nil, description: 'IMAGE DESCRIPTION') }
      its(:local_file_name) { is_expected.to eq('image-description') }
    end

    context 'when mime type is image, cap. and description are nil, and file_name exists' do
      before { @resource.update_attributes(caption: nil, description: nil, file_name: 'ORIGINAL FILE NAME') }
      its(:local_file_name) { is_expected.to eq('original-file-name') }
    end

    context 'when caption is not in Latin script' do
      before { @resource.update_attributes(caption: 'نين السياسة', description: nil, file_name: 'ORIGINAL FILE NAME') }
      its(:local_file_name) { is_expected.to eq('original-file-name') }
    end

    context 'when mime type is image, file_name is empty and all else is nil' do
      before { @resource.update_attributes(caption: nil, description: nil, file_name: '') }
      its(:local_file_name) { is_expected.to eq(@resource.cloud_resource_identifier.parameterize) }
    end

    describe 'when mime type is image and all else is nil' do
      before do
        @resource.update_attributes(caption: nil, description: nil, file_name: '')
        @resource.valid?
      end
      its(:local_file_name) { is_expected.to eq(@resource.cloud_resource_identifier.parameterize) }
    end
  end

  # pending '#delete_binaries'
end
