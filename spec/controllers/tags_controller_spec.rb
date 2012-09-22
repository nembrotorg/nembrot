require 'spec_helper'

describe TagsController do

  before(:each) do
      @tag = Note.tag_counts_on(:tags)
  end
  
  describe "GET #index" do
    it "populates an array of tags" do
      get :index
      assigns(:tags).should eq([@tag])
    end
    
    it "renders the :index view" do
      get :index
      response.should render_template :index
    end
  end

  describe "GET #show" do
    it "assigns the requested tag to @tag" do
      get :show, slug: @tag
      assigns(:tag).should eq(@tag)
    end
    
    it "renders the #show view" do
      get :show, slug: @tag
      response.should render_template :show
    end
  end

end
