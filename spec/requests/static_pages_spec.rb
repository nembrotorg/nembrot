require 'spec_helper'

describe "Static pages" do
  
  describe "Home page" do

  	before { visit '/' }

    it "should have the content 'Nembrot'" do
      page.should have_selector('h1', text: I18n.t('site.title'))
    end
    it "should have a link to Notes" do
      page.should have_link(I18n.t('notes.title'), href: notes_path)
    end
    it "should have a link to Tags" do
      page.should have_link(I18n.t('tags.title'), href: tags_path)
    end

  end

end
