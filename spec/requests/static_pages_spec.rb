require 'spec_helper'

describe "Static pages" do

  describe "Home page" do

  	before { visit '/' }

    it "should have the content 'Nembrot'" do
      page.should have_selector('h1')
    end

    it "should have the content 'Nembrot'" do
      visit '/'
      page.should have_selector('h1', text: 'Home - Nembrot')
    end

  end

end
