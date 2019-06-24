# encoding: utf-8

RSpec.describe CitationsController do
  before do
    @citation = FactoryGirl.create(:note, content_type: 1)
  end

  describe 'GET #index' do
    it 'populates an array of notes' do
      get :index
      expect(assigns(:citations)).to eq([@citation])
    end

    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    it 'assigns the requested citation to @citation' do
      get :show, id: @citation
      expect(assigns(:citation)).to eq(@citation)
    end

    it 'assigns the requested tags to @tags' do
      get :show, id: @citation
      expect(assigns(:tags)).to eq(@citation.tags)
    end

    it 'renders the #show view' do
      get :show, id: @citation
      expect(response).to render_template :show
    end

    context 'when the citation is not available' do
      before do
        get :show, id: 0
      end
      it { is_expected.to respond_with(:redirect) }
      it 'sets the flash' do
        expect(flash[:error]).to eq(I18n.t('citations.show.not_found', id: 0))
      end
    end
  end
end
