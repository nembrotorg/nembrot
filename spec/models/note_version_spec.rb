require 'spec_helper'

describe NoteVersion do

  let(:note) { FactoryGirl.build_stubbed(:note) }
  before {
    @note_version = FactoryGirl.build_stubbed(:note_version, :note => note)
  }

  subject { @note_version }

  it { should be_valid }
  it { should respond_to(:title) }
  it { should respond_to(:body) }
  it { should respond_to(:external_updated_at) }
  it { should respond_to(:note_id) }
  it { should respond_to(:version) }
  it { should respond_to(:note) }

  its(:note) { should == note }

  describe "accessible attributes" do
    it "should not allow access to note_id" do
      expect { NoteVersion.new(note_id: note.id) }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end

  describe "version should be 1" do
    # If we use the build/build_stubbed object, version won't have been calculated
    before { @note_version = FactoryGirl.create(:note_version, :note => note) }    
    its(:version) { should == 1 }
  end

  describe "when note_id is not present" do
    before { @note_version.note_id = nil }
    it { should_not be_valid }
  end

  describe "when title is not present" do
    before { @note_version.title = nil }
    it { should_not be_valid }
  end

  describe "when body is not present" do
    before { @note_version.body = nil }
    it { should_not be_valid }
  end

  describe "when external_updated_at is not present" do
    before { @note_version.external_updated_at = nil }
    it { should_not be_valid }
  end

  describe "assigns an incremented version number when a new version of an existing note is created" do
    before {
      @note_version  = FactoryGirl.create(:note_with_versions, versions_count: 7).note_versions.last
    }
    its(:version) { should == 7 }
  end

  describe "when a different external_identifier is used" do
    before {
      @note_version0 = FactoryGirl.create(:note_with_versions, external_identifier: 'ABC200').note_versions.last   
      @note_version  = FactoryGirl.create(:note_with_versions, external_identifier: 'ABC201').note_versions.last
    }
    its(:version) { should == 1 }
  end

  describe "when a more recent version of the same note exists" do
    before {
      @note_version_0 = FactoryGirl.create(:note_version, external_updated_at: 'Mon, 30 Jul 2012 12:00:00 UTC +00:00', :note => note) 
      @note_version = FactoryGirl.build(:note_version, external_updated_at: 'Mon, 30 Jul 2012 11:59:59 UTC +00:00', :note => note) 
    }
    it { should_not be_valid }
    it { should have(1).error_on( :external_updated_at ) }
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
