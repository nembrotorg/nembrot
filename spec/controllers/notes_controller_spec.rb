# encoding: utf-8

describe NotesController do

  before(:each) do
    @note = FactoryGirl.create(:note)
    @note.update_attributes(title: 'New Title')
    @note.update_attributes(title: 'Newer Title')
  end

  describe 'GET #index' do
    it 'populates an array of notes' do
      get :index
      assigns(:notes).should eq([@note])
    end

    it 'renders the :index view' do
      get :index
      response.should render_template :index
    end
  end

  describe 'GET #show' do
    it 'assigns the requested note to @note' do
      get :show, id: @note
      assigns(:note).should eq(@note)
    end

    it 'assigns the requested tags to @tags' do
      get :show, id: @note
      assigns(:tags).should eq(@note.tags)
    end

    it 'renders the #show view' do
      get :show, id: @note
      response.should render_template :show
    end

    context 'when the note is not available' do
      before do
        get :show, id: 0
      end
      it { should respond_with(:redirect) }
      it 'sets the flash' do
        flash[:error].should == I18n.t('notes.show.not_found', id: 0)
      end
    end
  end

  describe 'GET #version' do
    it 'assigns the requested note to @note', versioning: true do
      get :version, id: @note, sequence: 1
      assigns(:note).should eq(@note)
    end

    it 'assigns the requested version to @diffed_version', versioning: true do
      get :version, id: @note, sequence: 1
      assigns(:diffed_version).should be_an_instance_of(DiffedNoteVersion)
    end

    it 'renders the #version view', versioning: true  do
      get :version, id: @note, sequence: 1
      response.should render_template :version
    end

    context 'when the note is not available' do
      before do
        get :version, id: 0, sequence: 1
      end
      it { should respond_with(:redirect) }
      it 'sets the flash' do
        flash[:error].should == I18n.t('notes.show.not_found', id: 0)
      end
    end

    context 'when the version is not available' do
      before do
        get :version, id: @note, sequence: 999
      end
      it { should respond_with(:redirect) }
      it 'sets the flash' do
        flash[:error].should == I18n.t('notes.version.not_found', id: @note.id, sequence: 999)
      end
    end
  end
end
