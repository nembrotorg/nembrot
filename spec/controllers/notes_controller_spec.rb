require 'spec_helper'

describe NotesController do

  before(:each) do
      @note = FactoryGirl.create(:note)
    @note.update_attributes( :title => 'New Title')
    @note.update_attributes( :title => 'Newer Title')
  end
  
  describe "GET #index" do
    it "populates an array of notes" do
      get :index
      assigns(:notes).should eq([@note])
    end
    
    it "renders the :index view" do
      get :index
      response.should render_template :index
    end
  end

  describe "GET #show" do
    it "assigns the requested note to @note" do
      get :show, id: @note
      assigns(:note).should eq(@note)
    end
    
    it "assigns the requested note's tags to @tags" do
      get :show, id: @note
      assigns(:tags).should eq(@note.tags)
    end

    it "renders the #show view" do
      get :show, id: @note
      response.should render_template :show
    end

  end

  describe "GET #version" do
    it "assigns the requested note to @note", :versioning => true do
      get :version, id: @note, sequence: 1
      assigns(:note).should eq(@note)
    end
    
    it "assigns the requested version to @diffed_version", :versioning => true do
      get :version, id: @note, sequence: 1
      assigns(:diffed_version).should eq(@note.diffed_version(1))
    end

    it "renders the #version view", :versioning => true  do
      get :version, id: @note, sequence: 1
      response.should render_template :version
    end
  end

end
