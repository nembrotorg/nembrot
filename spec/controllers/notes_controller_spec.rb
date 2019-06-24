# encoding: utf-8

RSpec.describe NotesController do
  before(:example) do
    ENV['blurb_length'] = '40'
    ENV['version_gap_distance'] = '10'
    ENV['version_gap_minutes'] = '60'
    @note = FactoryGirl.create(:note, external_updated_at: 200.minutes.ago)
    @note.update_attributes(title: 'New Title', external_updated_at: 100.minutes.ago)
    @note.update_attributes(title: 'Newer Title', external_updated_at: 1.minute.ago)
  end

  describe 'GET #index' do
    it 'populates an array of notes' do
      get :index
      expect(assigns(:notes)).to eq([@note])
    end

    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    it 'assigns the requested note to @note' do
      get :show, id: @note
      expect(assigns(:note)).to eq(@note)
    end

    it 'assigns the requested tags to @tags' do
      get :show, id: @note
      expect(assigns(:tags)).to eq(@note.tags)
    end

    it 'renders the #show view' do
      get :show, id: @note
      expect(response).to render_template :show
    end

    context 'when the note is not available' do
      before do
        get :show, id: 0
      end
      it { is_expected.to respond_with(:redirect) }
      it 'sets the flash' do
        expect(flash[:error]).to eq(I18n.t('notes.show.not_found', id: 0))
      end
    end
  end

  describe 'GET #version' do
    it 'assigns the requested note to @note', versioning: true do
      get :version, id: @note, sequence: 1
      expect(assigns(:note)).to eq(@note)
    end

    it 'assigns the requested version to @diffed_version', versioning: true do
      get :version, id: @note, sequence: 1
      expect(assigns(:diffed_version)).to be_an_instance_of(DiffedNoteVersion)
    end

    it 'renders the #version view', versioning: true  do
      get :version, id: @note, sequence: 1
      expect(response).to render_template :version
    end

    context 'when the note is not available' do
      before do
        get :version, id: 0, sequence: 1
      end
      it { is_expected.to respond_with(:redirect) }
      it 'sets the flash' do
        expect(flash[:error]).to eq(I18n.t('notes.show.not_found', id: 0))
      end
    end

    context 'when the version is not available' do
      before do
        get :version, id: @note, sequence: 999
      end
      it { is_expected.to respond_with(:redirect) }
      it 'sets the flash' do
        expect(flash[:error]).to eq(I18n.t('notes.version.not_found', id: @note.id, sequence: 999))
      end
    end
  end
end
