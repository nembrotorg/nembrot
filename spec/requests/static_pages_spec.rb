require 'spec_helper'

describe "Static pages" do
  
  describe "Home page" do

  	before { visit '/' }

  	subject { page }

    it "should have the content 'Nembrotxx'" do
      page.should have_selector('h1', text: 'Nembrot')
    end
    it "should have a link to Notes" do
      page.should have_selector('a', text: 'Notes')
    end
    it "should have a link to Tags" do
      page.should have_selector('a', text: 'Tags')
    end

  end

end
