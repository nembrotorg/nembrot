# encoding: utf-8

describe CitationsController do

  before do
    @current_channel = FactoryGirl.create(:channel)
    @citation = FactoryGirl.create(:note, instruction_list: %w(__QUOTE))
  end

  describe 'GET #index' do
    it 'populates an array of notes' do
      get :index, channel: @current_channel
      assigns(:citations).should eq([@citation])
    end

    it 'renders the :index view' do
      get :index, channel: @current_channel
      response.should render_template :index
    end
  end

  describe 'GET #show' do
    it 'assigns the requested citation to @citation' do
      get :show, channel: @current_channel, id: @citation
      assigns(:citation).should eq(@citation)
    end

    it 'assigns the requested tags to @tags' do
      get :show, channel: @current_channel, id: @citation
      assigns(:tags).should eq(@citation.tags)
    end

    it 'renders the #show view' do
      get :show, channel: @current_channel, id: @citation
      response.should render_template :show
    end

    context 'when the citation is not available' do
      before do
        get :show, channel: @current_channel, id: 0
      end
      it { should respond_with(:redirect) }
      it 'sets the flash' do
        flash[:error].should == I18n.t('citations.show.not_found', id: 0)
      end
    end
  end
end
