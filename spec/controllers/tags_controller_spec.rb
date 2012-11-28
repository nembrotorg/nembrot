require 'spec_helper'

describe TagsController do
  
  describe "GET #index" do
    before(:each) do
        @tags = Note.tag_counts_on(:tags)
    end

    it "populates an array of tags" do
      get :index
      assigns(:tags).should eq(@tags)
    end
    
    it "renders the :index view" do
      get :index
      response.should render_template :index
    end
  end

  describe "GET #show" do
    before(:each) do
        @tag_name = Faker::Lorem.words(1)
        note = FactoryGirl.create(:note, :tag_list => @tag_name)
        @tag = Tag.first
    end

    it "assigns the requested tag to @tag" do
      get :show, slug: @tag_name
      assigns(:tag).should eq(@tag)
    end
    
    it "renders the #show view" do
      get :show, slug: @tag_name
      response.should render_template :show
    end
  end

end
