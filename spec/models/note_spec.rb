include ActionView::Helpers::SanitizeHelper
include ApplicationHelper

describe Note do

  before {
    @note = FactoryGirl.create(:note)
  }

  subject { @note }

  it { should be_valid }
  it { should respond_to(:title) }
  it { should respond_to(:body) }
  it { should respond_to(:external_updated_at) }
  it { should respond_to(:blurb) }
  it { should respond_to(:diffed_version) }

  it { should have_many(:cloud_notes) }
  it { should have_many(:resources) }
  it { should have_many(:tags).through(:tag_taggings) }
  it { should have_many(:instructions).through(:instruction_taggings) }
  it { should have_many(:versions) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }
  it { should validate_presence_of(:external_updated_at) }

  # Not yet implemented
  # describe "refuses update when external_updated_at is unchanged" do
  #   before { 
  #     @note.update_attributes(
  #         :title => "New Title",
  #         :external_updated_at => @note.external_updated_at
  #       )
  #   }
  #   it { should_not be_valid }
  #   it { should have(1).error_on(:external_updated_at) }
  # end

  # Not yet implemented
  # describe "refuses update when external_updated_at is older" do
  #   before { 
  #     @note.update_attributes(
  #         :title => "New Title",
  #         :external_updated_at => @note.external_updated_at - 1
  #       )
  #   }
  #   it { should_not be_valid }
  #   it { should have(1).error_on(:external_updated_at) }
  # end

  describe "uses body when title is missing" do
    before { @note.update_attributes( :title => I18n.t('notes.untitled_synonyms')[0] ) }
    its(:title) { should == snippet( @note.body, Settings.notes.title_length ) }
  end

  describe "uses title and body for blurb" do
    its(:blurb) { should == @note.title + ': ' + @note.body }
  end

  describe "omits title in blurb when title is derived from body" do
    before { @note.update_attributes( :title => I18n.t('notes.untitled_synonyms')[0] ) }
    its(:blurb) { should == @note.body }
  end

  describe "is taggable" do
    before { 
      @note.tag_list = "tag1, tag2, tag3"
      @note.save
    }
    its (:tag_list) { should == ["tag1", "tag2", "tag3"] }
  end

  describe "is findable by tag" do
    before {
      @note.update_attributes( :tag_list => "tag4" ) 
    }
    Note.tagged_with("tag4").last.should == @note
  end

  #describe "saves versions on every update", :versioning => true do
  #  before { 
  #    @note.update_attributes( :title => "New Title" ) 
  #  }
  #  @note.versions.length.should > 0
  #end

  #describe "diffed_version should return title and previous_title", :versioning => true do
  #  note = FactoryGirl.create(:note, :title => 'First Title', :tag_list => "tag1, tag2, tag3")
  #  note.update_attributes( :title => 'Second Title', :tag_list => "tag4, tag5, tag6")
    # Test that tags change
    # Test obsolete status
    #  note.diffed_version(1).sequence.should == 1
    #  note.diffed_version(1).title.should == 'First Title'
    #  note.diffed_version(1).previous_title.should == ''
    #  note.diffed_version(2).sequence.should == 2
    #  note.diffed_version(2).title.should == 'Second Title'
    #  note.diffed_version(2).previous_title.should == 'First Title'
  #end
end
