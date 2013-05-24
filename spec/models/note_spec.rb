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
  it { should respond_to(:active) }
  it { should respond_to(:author) }
  it { should respond_to(:source) }
  it { should respond_to(:source_url) }
  it { should respond_to(:source_application) }
  it { should respond_to(:last_edited_by) }
  it { should respond_to(:embeddable_source_url) }
  it { should respond_to(:fx) }
  it { should respond_to(:active) }
  it { should respond_to(:hide) }

  it { should have_many(:cloud_notes) }
  it { should have_many(:resources) }
  it { should have_many(:tags).through(:tag_taggings) }
  it { should have_many(:instructions).through(:instruction_taggings) }
  it { should have_many(:versions) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:external_updated_at) }

  describe "refuses update when body, embeddable url and resources are all nil" do
    before {
      @note.update_attributes(
        :body => nil,
        :source_url => nil
      )
    }
    it { should_not be_valid }
    it { should have(1).error_on(:note) }
  end

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
    its(:blurb) { should == '<h2>' + @note.title + '</h2>: ' + @note.body }
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

  #describe "accepts special characters in tags" do
  #  before { 
  #    @note.tag_list = "Žižek, Café, 井戸端"
  #    @note.save
  #  }
  #  its (:tag_list) { should == ["Žižek", "Café", "井戸端"] }
  #end

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

  describe "embeddable_source_url" do
    before {
      @note.source_url = 'http://www.example.com'
    }
    its(:embeddable_source_url) { should be_nil }
  end

  describe "embeddable_source_url should should return an embeddable youtube link if source_url is a youtube link" do
    before {
      @note.source_url = 'http://youtube.com?v=ABCDEF'
    }
    its(:embeddable_source_url) { should == 'http://www.youtube.com/embed/ABCDEF?rel=0' }
  end

  describe "embeddable_source_url should should return an embeddable vimeo link if source_url is a vimeo link" do
    before {
      @note.source_url = 'http://vimeo.com/video/ABCDEF'
    }
    its(:embeddable_source_url) { should == 'http://player.vimeo.com/video/ABCDEF' }
  end  

  describe "embeddable_source_url should should return an embeddable soundcloud link if source_url is a soundcloud link" do
    before {
      @note.source_url = 'http://soundcloud.com?v=ABCDEF'
    }
    its (:embeddable_source_url) { should == 'http://w.soundcloud.com/player/?url=http://soundcloud.com?v=ABCDEF' }
  end

  describe "note.fx should return fx for note's images" do
    before {
      @note.instruction_list = '__FX_ABC, __FX_DEF'
    }
    its (:fx) { should == 'abc_def' }
  end

# TEST PUBLISHABLE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
end
