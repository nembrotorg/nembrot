# encoding: utf-8

describe LinksController do

  before do
    @citation = FactoryGirl.create(:note)
    @link = FactoryGirl.create(:link)
    @link.notes << @citation
  end

  describe 'GET #admin' do
    it 'populates an array of @links' do
      get :admin
      assigns(:links).should eq([@link])
    end

    it 'renders the :admin view' do
      get :admin
      response.should render_template :admin
    end
  end

  describe 'GET #index' do
    it 'populates an array of @links' do
      get :index
      assigns(:channels).should eq({ @link.channel => 1 })
    end

    it 'populates an array of @links' do
      get :index
      assigns(:links_count).should == 1
    end

    it 'renders the :index view' do
      get :index
      response.should render_template :index
    end
  end

  describe 'GET #show_channel' do
    before do
      get :show_channel, slug: @link.channel
    end
    specify { assigns(:links_channel).should eq([@link]) }
    specify { assigns(:channel).should eq(@link.channel) }
    specify { assigns(:name).should eq(@link.name) }

    it 'renders the #show_channel view' do
      get :show_channel, slug: @link.channel
      response.should render_template :show_channel
    end

    context 'when link is not available' do
      before do
        get :show_channel, slug: 'nonexistent'
      end
      it { should respond_with(:redirect) }
      it 'sets the flash' do
        flash[:error].should == I18n.t('links.show_channel.not_found', channel: 'nonexistent')
      end
    end
  end

  describe 'PUT update' do
    context 'valid attributes' do
      it 'located the requested @link' do
        put :update, id: @link.id, link: FactoryGirl.attributes_for(:link)
        assigns(:link).should eq(@link)
      end

      it 'changes @links attributes' do
        put :update, id: @link.id, link: FactoryGirl.attributes_for(:link, author: 'New Author')
        @link.reload
        @link.author.should eq('New Author')
      end

      it 'redirects to @links admin index' do
        put :update, id: @link.id, link: FactoryGirl.attributes_for(:link)
        @link.reload
        response.should redirect_to links_admin_path
        flash[:success].should == I18n.t('links.edit.success', channel: @link.channel)
      end
    end

    context 'invalid attributes' do
      before do
        put :update, id: @link.id, link: FactoryGirl.attributes_for(:link, url: nil)
        @link.reload
      end
      it 'rejects invalid attributes' do
        @link.author.should_not eq('New Author')
      end

      it 'rejects invalid attributes' do
        response.should render_template :edit
      end

      it 'rejects invalid attributes' do
        flash[:error].should == I18n.t('links.edit.failure')
      end
    end
  end

end
