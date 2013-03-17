describe EvernoteNotesController do

  describe "GET #add_task" do

    before {
      get :add_task, :guid => 'ABC123'
    }
    it { should respond_with(:success) }
    # it { should render_template('cloud_service_mailer/auth_not_found') }

    pending "We need to test for when auth is present"
  end
end
