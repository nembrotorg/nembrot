describe TagsHelper do

  # These tests fail because the helper depends on the ActsAsTaggableOn initializer
  # and this is not loaded in the test environment.

  # This helper should be tested in Requests because the helper
  # needs to determine current page.

  # before {
  #   @tag = FactoryGirl.build_stubbed(:tag)
  #   @obsolete_tag = FactoryGirl.build_stubbed(:tag, :obsolete => true)
  # }

  # describe "link_to_tag_unless_obsolete" do

  #   it "should link to tags unless they are obsolete" do
  #     link_to_tag_unless_obsolete(@tag).should == "<a href=\"/tags/#{@tag.slug}\">#{@tag.name}</a>"
  #   end
    
  #   it "should not link to tags if they are obsolete" do
  #     link_to_tag_unless_obsolete(@obsolete_tag).should == @obsolete_tag.name
  #   end
  # end
end
