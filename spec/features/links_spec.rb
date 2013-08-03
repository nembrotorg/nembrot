# encoding: utf-8

describe 'Links' do

  let(:link) { FactoryGirl.create(:link) }
  let(:citation) { FactoryGirl.build(:note, links: [link], is_citation: true, body: 'Text. -- http://example.com') }

  describe 'index page' do
    before do
      visit links_path
    end
    it 'has the title Links' do
      page.should have_selector('h1', text: I18n.t('links.index.title'))
    end
    it 'has a link to the link' do
      page.should have_selector('a', link_path(link))
    end
  end

  describe 'show_channel page' do
    before do
      visit link_path(link.slug)
    end
    it 'has a link to the link cited' do
      page.should have_selector('a', citation_path(citation))
    end
    it 'has a blockquote' do
      "page.should have_css('figure')"
    end
  end
end
