describe HomeController do

  before(:each) do
    @note_for_home = FactoryGirl.create(:note, :instruction_list => Settings.home.instructions.required[0])
    @note = FactoryGirl.create(:note)
  end
  
  describe "GET #index" do
    it "populates an array of notes tagged with '__HOME'" do
      get :index
      assigns(:notes).should eq([@note_for_home])
    end
    
    it "renders the :index view" do
      get :index
      response.should render_template :index
    end
  end
end
