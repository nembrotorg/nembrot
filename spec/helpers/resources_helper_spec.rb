# encoding: utf-8

describe ResourcesHelper do

  describe 'cut_image_binary_path' do
    before do
      @note = FactoryGirl.build_stubbed(:note)
      @resource = FactoryGirl.create(:resource, note: @note)
    end
    it 'uses default settings for path to the cut the image' do
      cut_image_binary_path(@resource).should == "/resources/cut/#{ @resource.local_file_name }-#{ Settings.styling.images.standard.aspect.x }-#{ Settings.styling.images.standard.aspect.y }-#{ Settings.styling.images.standard.width }-#{ Settings.styling.images.snap }-#{ Settings.styling.images.gravity }-#{ Settings.styling.images.effects }-#{ @resource.id }.png"
    end

    context 'when cut_image_binary_path has note fx' do
      before { @note.instruction_list = '__FX_ABC' }
      it 'uses note#fx if they are set' do
        cut_image_binary_path(@resource).should == "/resources/cut/#{ @resource.local_file_name }-#{ Settings.styling.images.standard.aspect.x }-#{ Settings.styling.images.standard.aspect.y }-#{ Settings.styling.images.standard.width }-#{ Settings.styling.images.snap }-#{ Settings.styling.images.gravity }-#{ @note.fx }-#{ @resource.id }.png"
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
        cut_image_binary_path(@resource, options).should == "/resources/cut/#{ @resource.local_file_name }-5-4-100-0-ne-def-999.png"
      end
    end
  end

  describe 'round_nearest' do
    it 'rounds the number down if nearer' do
      instance_eval { round_nearest(33, 30) } .should == 30
    end

    it 'rounds number up if nearer' do
      instance_eval { round_nearest(57, 30) } .should == 60
    end
  end
end
