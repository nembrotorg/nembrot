# encoding: utf-8

RSpec.describe 'Citations' do
  before do
    @book = FactoryGirl.build(:book, slug: 'author-2001')
    @citation = FactoryGirl.build(:note, books: [@book], content_type: 1, body: "Text. -- (#{ @book.tag }), p. 1")
  end

  describe 'index page' do
    before do
      visit citations_path
    end
    it 'has the title Citations' do
      expect(page).to have_selector('h1', text: I18n.t('citations.index.title'))
    end
    it 'has a link to the citation' do
      expect(page).to have_selector('a', citation_path(@citation.id))
    end
  end

  describe 'show page' do
    before do
      visit citation_path(@citation)
    end
    it 'has the citation title' do
      expect(page).to have_selector('h1', @citation.headline)
    end
    it 'has a link to the book cited' do
      expect(page).to have_selector('a', book_path(@book.slug))
    end
    it 'has a blockquote' do
      # # pending "page.should have_css('blockquote')"
    end
  end
end
