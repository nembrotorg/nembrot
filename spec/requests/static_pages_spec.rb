require 'spec_helper'

describe "Static pages" do

  describe "Home page" do

    it "should have the content 'Nembrot'" do
      visit '/'
      page.should have_content('Nembrot')
    end
  end

end
