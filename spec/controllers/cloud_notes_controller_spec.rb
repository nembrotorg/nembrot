describe CloudNotesController do

  describe "GET #update_cloud" do

    before {
      get :add_evernote_task, :guid => 'ABC123'
    }
    it { should respond_with(:success) }
    # it { should render_template('cloud_service_mailer/auth_not_found') }

    pending "We need to test for when auth is present"
  end
end
