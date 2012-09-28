require 'spec_helper'

describe NotesController do

  DatabaseCleaner.clean

  before(:each) do
      @note = FactoryGirl.create(:note)
  end
  
  describe "GET #indexx" do
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
    
    it "renders the #show view" do
      get :show, id: @note
      response.should render_template :show
    end
  end

end
