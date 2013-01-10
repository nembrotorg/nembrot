describe CloudServicesController do

  describe "GET #auth_callback" do
  
    before {
      get :auth_callback, :provider => 'evernote'
    }
    it { should respond_with(:redirect) }
    it { should set_the_flash }
  end

  describe "GET #auth_failure" do
  
    before {
      get :auth_failure, :provider => 'evernote'
    }
    it { should respond_with(:redirect) }
    it { should set_the_flash }
  end
end
