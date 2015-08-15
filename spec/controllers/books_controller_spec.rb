# encoding: utf-8

RSpec.describe BooksController do
  before do
    ENV['books_section'] = 'true'
    @book = FactoryGirl.create(:book, tag: 'Author 2001')
    @note = FactoryGirl.create(:note, body: @book.tag)
  end

  describe 'GET #admin' do
    context 'when no user is signed in' do
      before do
        put :update, id: @book.id, book: FactoryGirl.attributes_for(:book, author: nil)
        @book.reload
        get :admin
      end
      it { is_expected.to respond_with(:redirect) }
    end
    context 'when a non-admin user is signed in' do
      before do
        @user = FactoryGirl.create(:user, role: 'other')
        sign_in @user
        put :update, id: @book.id, book: FactoryGirl.attributes_for(:book, author: nil)
        @book.reload
        get :admin
      end
      it { is_expected.to respond_with(:redirect) }
    end
    context 'when an admin user is signed in' do
      before do
        @user = FactoryGirl.create(:user)
        sign_in @user
        put :update, id: @book.id, book: FactoryGirl.attributes_for(:book, author: nil)
        @book.reload
      end
      it 'populates an array of books' do
        get :admin
        expect(assigns(:books)).to eq([@book])
      end

      it 'renders the :admin view' do
        get :admin
        expect(response).to render_template :admin
      end
    end
  end

  describe 'GET #index' do
    it 'populates an array of books' do
      get :index
      expect(assigns(:books)).to eq([@book])
    end

    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before do
      ENV['books_section'] = 'true'
      @related_book = FactoryGirl.create(:book, isbn_10: '0679768025', isbn_13: nil, author: @book.author)
      get :show, slug: @book.slug
    end
    it 'assigns the requested book to @book' do
      expect(assigns(:book)).to eq(@book)
    end

    it 'assigns books to @books' do
      expect(assigns(:books)).to eq([@book, @related_book])
    end

    it 'assigns related books to @related_books' do
      expect(assigns(:related_books)).to eq([@related_book])
    end

    it 'renders the #show view' do
      get :show, slug: @book.slug
      expect(response).to render_template :show
    end

    context 'when book is not available' do
      before do
        get :show, slug: 'nonexistent'
      end
      it { is_expected.to respond_with(:redirect) }
      it 'sets the flash' do
        expect(flash[:error]).to eq(I18n.t('books.show.not_found', slug: 'nonexistent'))
      end
    end
  end

  describe 'PUT update' do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    context 'valid attributes' do
      it 'located the requested @book' do
        put :update, id: @book.id, book: FactoryGirl.attributes_for(:book)
        expect(assigns(:book)).to eq(@book)
      end

      it 'changes @books attributes' do
        put :update, id: @book.id, book: FactoryGirl.attributes_for(:book, author: 'New Author')
        @book.reload
        expect(@book.author).to eq('New Author')
      end

      it 'redirects to books admin index' do
        put :update, id: @book.id, book: FactoryGirl.attributes_for(:book)
        @book.reload
        expect(response).to redirect_to books_admin_path
        expect(flash[:success]).to eq(I18n.t('books.edit.success', title: @book.title))
      end
    end

    context 'invalid attributes' do
      before do
        put :update, id: @book.id, book: FactoryGirl.attributes_for(:book, author: 'New Author', isbn_10: nil, isbn_13: nil)
        @book.reload
      end
      it 'rejects invalid attributes' do
        expect(@book.author).not_to eq('New Author')
      end

      it 'rejects invalid attributes' do
        expect(response).to render_template :edit
      end

      it 'rejects invalid attributes' do
        expect(flash[:error]).to eq(I18n.t('books.edit.failure'))
      end
    end
  end
end
