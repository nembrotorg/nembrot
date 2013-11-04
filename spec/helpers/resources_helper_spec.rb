# encoding: utf-8

describe ResourcesHelper do

  describe '#cut_image_binary_path' do
    before do
      @note = FactoryGirl.create(:note)
      @resource = FactoryGirl.create(:resource, note: @note)
    end
    it 'uses default settings for path to the cut the image' do
      cut_image_binary_path(@resource)
        .should == "/resources/cut/#{ @resource.local_file_name }-#{ Settings.styling.images.standard.aspect.x }-#{ Settings.styling.images.standard.aspect.y }-#{ Settings.styling.images.standard.width }-#{ Settings.styling.images.snap }-#{ Settings.styling.images.gravity }-#{ Settings.styling.images.effects }-#{ @resource.id }.png"
    end

    context 'when cut_image_binary_path has note fx' do
      before { @note.instruction_list = '__FX_ABC' }
      it 'uses note#fx if they are set' do
        cut_image_binary_path(@resource)
          .should == "/resources/cut/#{ @resource.local_file_name }-#{ Settings.styling.images.standard.aspect.x }-#{ Settings.styling.images.standard.aspect.y }-#{ Settings.styling.images.standard.width }-#{ Settings.styling.images.snap }-#{ Settings.styling.images.gravity }-#{ @note.fx }-#{ @resource.id }.png"
      end
    end

    context 'when cut_image_binary_path has custom settings' do
      it 'does not use defaults' do
        options = {
          aspect_x: 5,
          aspect_y: 4,
          width: 100,
          snap: 0,
          gravity: 'ne',
          effects: 'def',
          id: 999,
          format: 'jpeg'
        }
        cut_image_binary_path(@resource, options)
          .should == "/resources/cut/#{ @resource.local_file_name }-5-4-100-0-ne-def-999.png"
      end
    end
  end

  describe '#cut_image_binary' do
    before do
      note = FactoryGirl.create(:note)
      @resource = FactoryGirl.create(:resource, note: note)
    end
    context 'when the raw image exists' do
      it 'creates an image file' do
        # If a raw file already exists, we do not create a new one, nor do we delete it afterwards.
        preexisting_raw_file = File.exists? @resource.raw_location
        FileUtils.cp(@resource.blank_location, @resource.raw_location) unless preexisting_raw_file
        cut_image_binary(@resource.local_file_name, 'png', 16, 9, 100, 1, 0, '').should == @resource.cut_location(16, 9, 100, 1, 0, '')
        File.exists?(@resource.cut_location(16, 9, 100, 1, 0, '')).should == true
        File.delete @resource.cut_location(16, 9, 100, 1, 0, '')
        File.delete @resource.raw_location unless preexisting_raw_file
      end
    end
    context 'when the raw image does not exist' do
      it 'returns a blank image' do
        # If a raw file already exists, we temporarily rename it.
        preexisting_raw_file = File.exists? @resource.raw_location
        File.rename(@resource.raw_location, "#{ @resource.raw_location }-stashed") if preexisting_raw_file
        cut_image_binary(@resource.local_file_name, 'png', 16, 9, 100, 1, 0, '').should == @resource.blank_location
        File.rename("#{ @resource.raw_location }-stashed", @resource.raw_location) if preexisting_raw_file
      end
    end
    context 'when the image record is not found' do
      it 'returns a blank image' do
        cut_image_binary( 'NONEXISTENT', 'png', 16, 9, 100, 1, 0, '').should == Settings.blank_image_location
      end
    end
  end

  describe '#round_nearest' do
    context 'when number is closer to lower snap' do
      it 'rounds the number down if nearer' do
        round_nearest(33, 30).should == 30
      end
    end
    context 'when number is closer to higher snap' do
      it 'rounds number up if nearer' do
        round_nearest(57, 30).should == 60
      end
    end
  end

  describe '#column_width' do
    before do
      Settings.styling['column_width'] = 60
      Settings.styling['gutter_width'] = 30
    end
    it 'calculates the right width' do
      column_width(3).should == 240
    end
  end
end
