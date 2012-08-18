require 'spec_helper'

describe NotesController do

  before(:each) do
      @note = FactoryGirl.create(:note_with_versions)
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
      assigns(:note).should eq(@note.note_versions.last)
    end
    
    it "renders the #show view" do
      get :show, id: @note
      response.should render_template :show
    end
  end

end
