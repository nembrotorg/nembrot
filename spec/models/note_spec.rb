require 'spec_helper'

describe Note do

  let( :third_party ) { FactoryGirl.build_stubbed( :third_party ) }
  let( :external ) { FactoryGirl.build_stubbed( :external, :third_party => third_party ) }
  before {
    @note = FactoryGirl.build_stubbed( :note, :external => external }
  }

  subject { @note }

  it { should be_valid }
  it { should respond_to(:title) }
  it { should respond_to(:body) }
  it { should respond_to(:external_updated_at) }
  it { should respond_to(:external_id) }
  it { should respond_to(:external) }

  its(:external) { should == external }

  describe "when title is not present" do
    before { @note.title = nil }
    it { should_not be_valid }
    it { should have(1).error_on(:title) }
  end

  describe "when body is not present" do
    before { @note.body = nil }
    it { should_not be_valid }
    it { should have(1).error_on(:body) }
  end

  describe "when external_updated_at is not present" do
    before { @note.external_updated_at = nil }
    it { should_not be_valid }
    it { should have(1).error_on(:external_updated_at) }
  end

  describe "when external_id is not present" do
    before { @note.external_updated_at = nil }
    it { should_not be_valid }
    it { should have(1).error_on(:external_id) }
  end

  describe "when external_id is not unique" do
    before { 
      @note0 = FactoryGirl.create(:note, :external_id => 1)
      @note = FactoryGirl.build_stubbed(:note, :external_id => 1)
    }
    it { should_not be_valid }
    it { should have(1).error_on(:external_id) }
  end

  describe "accessible attributes" do
    it "should not allow access to note_id" do
      expect { NoteVersion.new(note_id: note.id) }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end

  describe "accepts tags and is findable by tags" do
    @note_version = FactoryGirl.create(:note_version, :tag_list => "tag1, tag2, tag3")
    @note_version.tag_list.should == ["tag1", "tag2", "tag3"]
  end

  describe "is findable by tag" do
    tag = Faker::Lorem.words(1)
    @note_version = FactoryGirl.create(:note_version, :tag_list => tag)
    NoteVersion.tagged_with(tag).first.should == @note_version
  end
end
