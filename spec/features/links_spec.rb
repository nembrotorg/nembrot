# encoding: utf-8

RSpec.describe 'Links' do
  before(:example) do
    @note = FactoryGirl.build(:note, content_type: 2)
    Url.new(@note)
    @note.url_title = 'Test title' # Avoid discrepancies caused by formatting
    @note.save!
  end

  describe 'index page' do
    before do
      visit links_path
    end
    it 'has the title Links' do
      expect(page).to have_selector('h1', text: I18n.t('links.index.title'))
    end
    it 'has the link title' do
      expect(page).to have_text(@note.url_title)
    end
    it 'has the link lede' do
      expect(page).to have_text(@note.url_lede)
    end
    it 'has a link to the url' do
      expect(page).to have_selector('.links a', @note.url)
    end
  end
end
