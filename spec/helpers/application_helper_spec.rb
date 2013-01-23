describe ApplicationHelper do
  
  describe "lang_attr" do
    before {
      I18n.locale ='en'
    }
    it "should return the language if different from locale" do
      lang_attr('ar').should == 'ar'
    end
    it "should return nil if the language is same as locale" do
      lang_attr('en').should == nil
    end
  end

  describe "body_dir_attr" do
    before {
      Settings.lang['rtl_langs'] = ['ar']
    }
    it "should return 'rtl' if language is rtl" do
      body_dir_attr('ar').should == 'rtl'
    end
    it "should return nil if language is not rtl" do
      body_dir_attr('en').should == nil
    end
  end

  describe "dir_attr" do
    before {
      Settings.lang['rtl_langs'] = ['ar']
      I18n.locale = 'en'
    }
    it "should return nil if language is the same as locale" do
      dir_attr('en').should == nil
    end
    it "should return 'rtl' if language is not the same as locale, and is rtl" do
      dir_attr('ar').should == 'rtl'
    end
  end

  describe "dir_attr" do
    before {
      Settings.lang['rtl_langs'] = ['ar']
      I18n.locale = 'ar'
    }
    it "should return 'ltr' if language is not the same as locale, and is ltr" do
      dir_attr('en').should == 'ltr'
    end
    it "should return nil if language is the same as locale, and is rtl" do
      dir_attr('ar').should == nil
    end
  end

  describe "Snippet" do
    it "should not truncate string if it contains fewer words than required" do
      snippet("One two three", 4).should == "One two three"
    end

    it "should not truncate string if it contains as many words as required" do
      snippet("One two three four", 4).should == "One two three four"
    end

    it "should truncate string and add ellipses if it contains more words than required" do
      snippet("One two three four", 3).should == "One two three..."
    end
  end

  describe "Bodify" do
    it "should wrap multiple paragraphs in <p> tags" do
      bodify("Plain text\nMore plain text").should == "<p>Plain text</p>\n<p>More plain text</p>"
    end
  end
end
