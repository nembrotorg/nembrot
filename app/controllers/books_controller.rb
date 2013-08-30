class BooksController < ApplicationController

  add_breadcrumb I18n.t('books.index.title'), :books_path

  def index
    @books = Book.cited
    @references_count = @books.to_a.sum { |b| b.notes.size }

    respond_to do |format|
      format.html
      format.json { render json: @books }
    end
  end

  def admin
    case params[:mode]
    when 'all'
      @books = Book.editable
    when 'citable'
      @books = Book.citable
    when 'cited'
      @books = Book.cited
    else
      @books = Book.metadata_missing
    end

    @mode = params[:mode].nil? ? 'missing metadata' : params[:mode]

    add_breadcrumb I18n.t('books.admin.title_short'), books_admin_path
    add_breadcrumb @mode, request.original_url

    respond_to do |format|
      format.html
      format.json { render json: @books }
    end
  end

  def show
    @books = Book.cited
    @book = @books.find_by_slug(params[:slug])
    @related_books = @books.where(author: @book.author).where('books.id <> ?', @book.id)

    add_breadcrumb @book.headline, book_path(params[:slug])

    respond_to do |format|
      format.html
      format.json { render json: @book }
    end
    rescue
      flash[:error] = t('books.show.not_found', slug: params[:slug])
      redirect_to books_path
  end

  def edit
    @book = Book.find params[:id]

    add_breadcrumb I18n.t('books.admin.title_short'), books_admin_path
    add_breadcrumb "ISBN #{ @book.isbn }", edit_book_path(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def update
    @book = Book.find_by_id(params[:id])
   
    add_breadcrumb I18n.t('books.admin.title_short'), books_admin_path
    add_breadcrumb "ISBN #{ @book.isbn }", edit_book_path(params[:id])

    if @book.update_attributes(book_params)
      flash[:success] = I18n.t('books.edit.success', title: @book.title)
      redirect_to books_admin_path
    else
      flash[:error] = I18n.t('books.edit.failure')
      render :edit
    end
  end

  private

  def book_params
    params.require(:book).permit(:attempts, :author, :dewey_decimal, :dimensions, :dirty, :editor, :format,
                                 :full_text_url, :google_books_id, :introducer, :isbn_10, :isbn_13, :lang, :lcc_number,
                                 :library_thing_id, :notes, :open_library_id, :page_count, :pages, :published_city, 
                                 :published_date, :publisher, :tag, :title, :translator, :weight)
  end

end
