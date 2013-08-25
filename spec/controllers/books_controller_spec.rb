# encoding: utf-8

describe BooksController do

  before do
    @book = FactoryGirl.create(:book, tag: 'Author 2001')
    @note = FactoryGirl.create(:note, body: @book.tag)
  end

  describe 'GET #admin' do
    before do
      put :update, id: @book.id, book: FactoryGirl.attributes_for(:book, author: nil)
      @book.reload
    end
    it 'populates an array of books' do
      get :admin
      assigns(:books).should eq([@book])
    end

    it 'renders the :admin view' do
      get :admin
      response.should render_template :admin
    end
  end

  describe 'GET #index' do
    it 'populates an array of books' do
      get :index
      assigns(:books).should eq([@book])
    end

    it 'renders the :index view' do
      get :index
      response.should render_template :index
    end
  end

  describe 'GET #show' do
    before do
      @related_book = FactoryGirl.create(:book, isbn_10: '0679768025', isbn_13: nil, author: @book.author)
      get :show, slug: @book.slug
    end
    it 'assigns the requested book to @book' do
      assigns(:book).should eq(@book)
    end

    it 'assigns books to @books' do
      assigns(:books).should eq([@book, @related_book])
    end

    it 'assigns related books to @related_books' do
      assigns(:related_books).should eq([@related_book])
    end

    it 'renders the #show view' do
      get :show, slug: @book.slug
      response.should render_template :show
    end

    context 'when book is not available' do
      before do
        get :show, slug: 'nonexistent'
      end
      it { should respond_with(:redirect) }
      it 'sets the flash' do
        flash[:error].should == I18n.t('books.show.not_found', slug: 'nonexistent')
      end
    end
  end

  describe 'PUT update' do
    context 'valid attributes' do
      it 'located the requested @book' do
        put :update, id: @book.id, book: FactoryGirl.attributes_for(:book)
        assigns(:book).should eq(@book)
      end

      it 'changes @books attributes' do
        put :update, id: @book.id, book: FactoryGirl.attributes_for(:book, author: 'New Author')
        @book.reload
        @book.author.should eq('New Author')
      end

      it 'redirects to books admin index' do
        put :update, id: @book.id, book: FactoryGirl.attributes_for(:book)
        @book.reload
        response.should redirect_to books_admin_path
        flash[:success].should == I18n.t('books.edit.success', title: @book.title)
      end
    end

    context 'invalid attributes' do
      before do
        put :update, id: @book.id, book: FactoryGirl.attributes_for(:book, author: 'New Author', isbn_10: nil, isbn_13: nil)
        @book.reload
      end
      it 'rejects invalid attributes' do
        @book.author.should_not eq('New Author')
      end

      it 'rejects invalid attributes' do
        response.should render_template :edit
      end

      it 'rejects invalid attributes' do
        flash[:error].should == I18n.t('books.edit.failure')
      end
    end
  end

end
