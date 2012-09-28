require 'spec_helper'

describe "Notes pages" do

  describe "Notes index page" do
  	before { 
      visit '/notes' }
    it "should have the content 'Nembrotx'" do
      page.should have_selector('h1', text: 'Nembrot')
    end
    it "should have a link to Notes" do
      page.should have_selector('a', text: 'Notes')
    end
  end

  describe "Notes show pagex" do
  	before { 
      note = FactoryGirl.create(:note)
      visit note_path(note)
    }
    it "should have the note title as title" do
      page.should have_selector('h1', text: note.title)
    end
    it "should have a link to Notes" do
      page.should have_selector('a', text: 'Notes')
    end
  end

  describe "Notes version page" do
  	before { visit '/' }
    it "should have the content 'Nembrot'" do
      page.should have_selector('h1', text: 'Nembrot')
    end
    it "should have a link to Notes" do
      page.should have_selector('a', text: 'Notes')
    end
  end

end
