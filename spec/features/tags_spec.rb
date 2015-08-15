# encoding: utf-8

RSpec.describe 'Tags pages' do
  before do
    ENV['tags_minimum'] = '1'
    @note = FactoryGirl.create(:note)
    @note.update_attributes(tag_list: ['tag1'])
    @tag = @note.tags[0]
  end

  describe 'Tags index page' do
    before { visit tags_path }
    it 'has the title Tags' do
      expect(page).to have_selector('h1', text: I18n.t('tags.index.title'))
    end
    it 'has a link to tag 1' do
      expect(page).to have_link(@tag.name, href: tag_path(@tag.slug))
    end

    context 'when this tag is attached to fewer notes than threshold' do
      before { ENV['tags_minimum'] = '10' }
      it 'does not have a link to tag 1' do
        # # pending 'page.should_not have_link(@tag.name, href: tag_path(@tag.slug))'
      end
    end
  end

  describe 'Tags index page' do
    before do
      @note.update_attributes(active: false)
      visit tags_path
    end
    it 'does not have a link to a tag belonging to an inactive note' do
      expect(page).not_to have_link(@tag.name, href: tag_path(@tag.slug))
    end
  end

  describe 'Tag show page' do
    before do
      @note.update_attributes(title: 'New title', body: 'New body')
      visit tag_path(@tag)
    end
    it 'has the tag title as title' do
      expect(page).to have_selector('h1', text: @tag.name)
    end
    it 'has a link to note' do
      expect(page).to have_selector('a', note_path(@note))
    end
  end

  describe 'Tag show page' do
    before do
      @note.update_attributes(title: 'New title', body: 'New body', active: false)
      visit tag_path(@tag)
    end
    it 'does not have a link to an inactive note' do
      expect(page).not_to have_selector('a', text: 'New title: New body')
      expect(page).not_to have_link('New title: New body', href: note_path(@note))
    end
  end
end
