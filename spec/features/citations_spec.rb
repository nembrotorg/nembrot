# encoding: utf-8

describe 'Citations' do

  before do
    @book = FactoryGirl.create(:book)
    @citation = FactoryGirl.create(:note, books: [@book], is_citation: true, body: "Text. -- (#{ @book.tag }), p. 1")
  end

  describe 'index page' do
    before do
      visit citations_path
    end
    it 'has the title Citations' do
      page.should have_selector('h1', text: I18n.t('citations.index.title'))
    end
    it 'has a link to the citation' do
      page.should have_selector('a', citation_path(@citation.id))
    end
  end

  describe 'show page' do
    before do
      visit citation_path(@citation)
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
