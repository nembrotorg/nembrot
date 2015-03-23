class BooksController < ApplicationController

  load_and_authorize_resource

  add_breadcrumb I18n.t('books.index.title'), :books_path

  def index
    page_number = params[:page] ||= 1
    all_books = Book.cited

    @books = all_books.page(page_number).load
    @books_count = all_books.size
    @references_count = all_books.to_a.sum { |b| b.notes.size }
  end

  def admin
    @mode = params[:mode] || 'missing_metadata'
    @books = Book.send(@mode)

    add_breadcrumb I18n.t('books.admin.title_short'), books_admin_path
    add_breadcrumb @mode.humanize, request.original_url
  end

  def show
    @books = Book.cited
    @book = @books.friendly.find(params[:slug])
    @related_books = @books.where(author: @book.author).where('books.id <> ?', @book.id)

    add_breadcrumb @book.headline, book_path(params[:slug])

    rescue
      flash[:error] = t('books.show.not_found', slug: params[:slug])
      redirect_to books_path
  end

  def edit
    @book = Book.find params[:id]

    add_breadcrumb I18n.t('books.admin.title_short'), books_admin_path
    add_breadcrumb "ISBN #{ @book.isbn }", edit_book_path(params[:id])
  end

  def update
    @book = Book.find_by_id(params[:id])

    add_breadcrumb I18n.t('books.admin.title_short'), books_admin_path
    add_breadcrumb "ISBN #{ @book.isbn }", edit_book_path(params[:id])

    @book.dirty = false # Book is assumed usable after a manual update

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
