# encoding: utf-8

describe 'Citations' do

  before do
    @book = FactoryGirl.create(:book)
    @citation = FactoryGirl.create(:note, books: [@book], is_citation: true, body: "Text. -- (#{ @book.tag }), p. 1")
  end

  describe 'index page' do
    before do
      visit books_path
    end
    it 'has the title Bibliography' do
      page.should have_selector('h1', text: I18n.t('books.index.title'))
    end
    it 'has a link to the book' do
      page.should have_selector('a', citation_path(@book.id))
    end
  end

  describe 'show page' do
    before do
      visit book_path(@citation)
    end
    it 'has the citation title' do
      page.should have_selector('h1', @citation.headline)
    end
    it 'has a link to the book cited' do
      page.should have_selector('a', book_path(@book.slug))
    end
    it 'has a blockquote' do
      pending "page.should have_css('blockquote')"
    end
  end
end
