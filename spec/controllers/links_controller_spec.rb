# encoding: utf-8

describe LinksController do

  before do
    @citation = FactoryGirl.create(:note)
    @link = FactoryGirl.create(:link)
    @link.notes << @citation
  end

  describe 'GET #admin' do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    it 'populates an array of @links' do
      get :admin
      expect(assigns(:links)).to eq([@link])
    end

    it 'renders the :admin view' do
      get :admin
      expect(response).to render_template :admin
    end
  end

  describe 'GET #admin' do
    context 'when no user is signed in' do
      before do
        get :admin
      end
      it { is_expected.to respond_with(:redirect) }
    end
    context 'when a non-admin user is signed in' do
      before do
        @user = FactoryGirl.create(:user, role: 'other')
        sign_in @user
        get :admin
      end
      it { is_expected.to respond_with(:redirect) }
    end
    context 'when an admin user is signed in' do
      before do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end
      it 'populates an array of @links' do
        get :admin
        expect(assigns(:links)).to eq([@link])
      end

      it 'renders the :admin view' do
        get :admin
        expect(response).to render_template :admin
      end
    end
  end

  describe 'GET #index' do
    it 'populates an array of @links' do
      get :index
      expect(assigns(:channels)).to eq([[@link.channel, 1]])
    end

    it 'populates an array of @links' do
      get :index
      expect(assigns(:links_count)).to eq(1)
    end

    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #show_channel' do
    before do
      get :show_channel, slug: @link.channel
    end
    specify { expect(assigns(:links_channel)).to eq([@link]) }
    specify { expect(assigns(:channel)).to eq(@link.channel) }
    specify { expect(assigns(:name)).to eq(@link.name) }

    it 'renders the #show_channel view' do
      get :show_channel, slug: @link.channel
      expect(response).to render_template :show_channel
    end

    context 'when link is not available' do
      before do
        get :show_channel, slug: 'nonexistent'
      end
      it { is_expected.to respond_with(:redirect) }
      it 'sets the flash' do
        expect(flash[:error]).to eq(I18n.t('links.show_channel.not_found', channel: 'nonexistent'))
      end
    end
  end

  describe 'PUT update' do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    context 'valid attributes' do
      it 'located the requested @link' do
        put :update, id: @link.id, link: FactoryGirl.attributes_for(:link)
        expect(assigns(:link)).to eq(@link)
      end

      it 'changes @links attributes' do
        put :update, id: @link.id, link: FactoryGirl.attributes_for(:link, author: 'New Author')
        @link.reload
        expect(@link.author).to eq('New Author')
      end

      it 'redirects to @links admin index' do
        put :update, id: @link.id, link: FactoryGirl.attributes_for(:link)
        @link.reload
        expect(response).to redirect_to links_admin_path
        expect(flash[:success]).to eq(I18n.t('links.edit.success', channel: @link.channel))
      end
    end

    context 'invalid attributes' do
      before do
        put :update, id: @link.id, link: FactoryGirl.attributes_for(:link, url: nil)
        @link.reload
      end
      it 'rejects invalid attributes' do
        expect(@link.author).not_to eq('New Author')
      end

      it 'rejects invalid attributes' do
        expect(response).to render_template :edit
      end

      it 'rejects invalid attributes' do
        expect(flash[:error]).to eq(I18n.t('links.edit.failure'))
      end
    end
  end

end
