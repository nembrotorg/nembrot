require 'spec_helper'

describe "Notes" do
  before {
    @note = FactoryGirl.create(:note)
  }

  describe "index page" do
  	before {
      @note.update_attributes( :title => 'New title', :body => 'New body' )
      visit notes_path
    }
    it "should have the title 'Notes'" do
      page.should have_selector('h1', text: I18n.t('notes.title'))
    end
    it "should have a link to note" do
      page.should have_link('New title: New body', href: note_path(@note))
    end
  end

  describe "show page" do
  	before {
      @note.update_attributes( :tag_list => 'tag1' )
      visit note_path(@note)
    }
    it "should have the note title as title" do
      page.should have_selector('h1', text: @note.title)
    end
    it "should have a link to Notes" do
      page.should have_link(I18n.t('notes.title'), href: notes_path)
    end
    it "should have a link to Tags" do
      page.should have_link(I18n.t('tags.title'), href: tags_path)
    end
    it "should have a link to tag1" do
      page.should have_link('tag1', href: '/tags/tag1')
    end
    it "should have a static label for Version 1" do
      page.should have_selector('li', text: 'v1')
    end
  end

  describe "version page", :versioning => true do
    before {
      @note.update_attributes( :title => 'Newer title', :body => 'Newer body', :tag_list => 'tag1' )
      @note.update_attributes( :title => 'Newest title', :body => 'Newest body', :tag_list => 'tag2' )
      visit note_version_path(@note, 3)
    }
    it "should have the note title as title" do
      page.should have_selector('h1', text: @note.title)
    end
    it "should have a link to Notes" do
      page.should have_link(I18n.t('notes.title'), href: notes_path)
    end
    it "should have a link to Tags" do
      page.should have_link(I18n.t('tags.title'), href: tags_path)
    end
    it "should have a diffed title" do
      page.should have_selector('del', text: 'Newer')
      page.should have_selector('ins', text: 'Newest')
    end
    it "should have a diffed body" do
      page.should have_selector('del', text: 'Newer')
      page.should have_selector('ins', text: 'Newest')
    end
    it "should have diffed tags" do
      page.should have_selector('del', text: 'tag1')
      page.should have_selector('ins', text: 'tag2')
    end
    it "should have a link to Version 1" do
      page.should have_link('v1', href: note_version_path(@note, 1))
    end
  end

end
