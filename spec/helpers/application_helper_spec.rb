require 'spec_helper'

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
    it "should strip html tags" do
      bodify("<div class='superfluous'><b>Plain text</b></div>").should == "<p>Plain text</p>"
    end

    it "should not strip links" do
      bodify("Plain text<a href='http://example.com'>example</a>").should == "<p>Plain text<a href=\"http://example.com\">example</a></p>"
    end

    it "should not strip ordered lists" do
      bodify("Plain text<ol><li>first</li></ol>").should == "<p>Plain text<ol><li>first</li></ol></p>"
    end

    it "should not strip unordered lists" do
      bodify("Plain text<ul><li>first</li></ul>").should == "<p>Plain text<ul><li>first</li></ul></p>"
    end

    it "should strip all attributes (except href)" do
      bodify("Plain text<ul class='superfluous'><li id='superfluous'>first</li></ul>").should == "<p>Plain text<ul><li>first</li></ul></p>"
    end

    it "should wrap paragraphs in <p> tags" do
      bodify("Plain text").should == "<p>Plain text</p>"
    end

    it "should strip doctype" do
      bodify("<!DOCTYPE html>Plain text").should == "<p>Plain text</p>"
    end
  end

end
