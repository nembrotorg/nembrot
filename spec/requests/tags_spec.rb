require 'spec_helper'

describe "Tags pages" do

  describe "Tags index page" do
  	before { visit '/' }
    it "should have the content 'Nembrot'" do
      page.should have_selector('h1', text: 'Nembrot')
    end
    it "should have a link to Notes" do
      page.should have_selector('a', text: 'Notes')
    end
  end

  describe "Tags show page" do
  	before { visit '/' }
    it "should have the content 'Nembrot'" do
      page.should have_selector('h1', text: 'Nembrot')
    end
    it "should have a link to Notes" do
      page.should have_selector('a', text: 'Notes')
    end
  end

end
