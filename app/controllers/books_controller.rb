class BooksController < ApplicationController

  add_breadcrumb I18n.t('books.title'), :books_path

  def index
    @books = Book.publishable

    respond_to do |format|
      format.html
      format.json { render :json => @books }
    end
  end

  def show
    @books = Book.publishable
    @book = @books.find_by_slug(params[:slug])

    add_breadcrumb @book.headline, book_path(params[:slug])

    respond_to do |format|
      format.html
      format.json { render :json => @notes }
    end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Book: #{ params[:slug] } does not exist."
      redirect_to books_path
  end
end
