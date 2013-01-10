
describe ApplicationHelper do
  
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
