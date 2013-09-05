# encoding: utf-8

describe 'Tags pages' do

  before do
    @note = FactoryGirl.create(:note)
    @note.update_attributes(tag_list: ['tag1'])
    @tag = @note.tags[0]
  end

  describe 'Tags index page' do
    before { visit tags_path }
    it 'has the title Tags' do
      page.should have_selector('h1', text: I18n.t('tags.index.title'))
    end
    it 'has a link to tag 1' do
      page.should have_link(@tag.name, href: tag_path(@tag.slug))
    end
  end

  describe 'Tags index page' do
    before do
      @note.update_attributes(active: false)
      visit tags_path
    end
    it 'does not have a link to a tag belonging to an inactive note' do
      page.should_not have_link(@tag.name, href: tag_path(@tag.slug))
    end
  end

  describe 'Tag show page' do
    before do
      @note.update_attributes( title: 'New title', body: 'New body' )
      visit tag_path(@tag)
    end
    it 'has the tag title as title' do
      page.should have_selector('h1', text: @tag.name)
    end
    it 'has a link to note' do
      page.should have_selector('a', note_path(@note))
    end
  end

  describe 'Tag show page' do
    before do
      @note.update_attributes(title: 'New title', body: 'New body', active: false)
      visit tag_path(@tag)
    end
    it 'does not have a link to an inactive note' do
      page.should_not have_selector('a', text: 'New title: New body')
      page.should_not have_link('New title: New body', href: note_path(@note))
    end
  end
end
