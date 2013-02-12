describe ResourcesHelper do
  
  describe "cut_image_path" do
    before {
      @note = FactoryGirl.build_stubbed(:note)
      @resource = FactoryGirl.create(:resource, :note => @note)
    }
    it "should use default settings for path to the cut image" do
      cut_image_path( @resource ).should == "/resources/cut/#{ @resource.local_file_name }-#{ Settings.styling.images.standard.aspect.x }-#{ Settings.styling.images.standard.aspect.y }-#{ Settings.styling.images.standard.width }-#{ Settings.styling.images.snap }-#{ Settings.styling.images.gravity }-#{ Settings.styling.images.effects }.png"
    end
  
    describe "cut_image_path with note fx" do
      before {
        @note.instruction_list = '__FX_ABC'
      }
      it "should use note's fx if they are set" do
        cut_image_path( @resource ).should == "/resources/cut/#{ @resource.local_file_name }-#{ Settings.styling.images.standard.aspect.x }-#{ Settings.styling.images.standard.aspect.y }-#{ Settings.styling.images.standard.width }-#{ Settings.styling.images.snap }-#{ Settings.styling.images.gravity }-#{ @note.fx }.png"
      end
    end

    describe "cut_image_path with custom settings" do
      it "should not use defaults" do
        options = {
          :aspect_x => 5,
          :aspect_y => 4,
          :width => 100,
          :snap => 0,
          :gravity => 'ne',
          :effects => 'def',
          :format => 'jpeg'
        }
        cut_image_path( @resource, options ).should == "/resources/cut/#{ @resource.local_file_name }-5-4-100-0-ne-def.png"
      end
    end
  end

  describe "round_nearest" do
    it "should round number down if nearer" do
      instance_eval{ round_nearest(33, 30) }.should == 30
    end

    it "should round number up if nearer" do
      instance_eval{ round_nearest(57, 30) }.should == 60
    end
  end
end
