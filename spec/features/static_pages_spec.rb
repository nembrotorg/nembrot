# encoding: utf-8

RSpec.describe 'Static pages' do
  describe 'Home page' do
    before { visit '/' }

    it 'has a link to Notes' do
      expect(page).to have_link(I18n.t('notes.index.title'), href: notes_path)
    end
    it 'has a link to Tags' do
      expect(page).to have_link(I18n.t('tags.index.title'), href: tags_path)
    end
  end
end
