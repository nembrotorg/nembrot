RSpec.describe EvernoteNotesController do
  describe 'GET #add_task' do
    before { get :add_task, guid: 'ABC123' }
    # FIXME: Evernote module has changed the way it gives out errors
    # # pending "it { should render_template('cloud_service_mailer/auth_not_found') }"

    # it { should respond_with(:success) }
    # # pending 'We need to test for when auth is present'
  end
end
