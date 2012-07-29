require 'spec_helper'

describe NoteVersion do
	it "has a valid factory" do
		FactoryGirl.create( :note_version ).should be_valid
	end
	it "is invalid without a title" do
		note_version = FactoryGirl.build( :note_version, title: nil )
  		note_version.should_not be_valid
  		note_version.should have(1).error_on( :title ) 
	end
	it "is invalid without a body" do
		note_version = FactoryGirl.build( :note_version, body: nil )
  		note_version.should_not be_valid
  		note_version.should have(1).error_on( :body ) 
	end
	it "creates a new note if one with the same external_note_id does not exist" do
		note_version = FactoryGirl.create( :note_version, external_note_id: 'NEWNOTE' )
  		Note.where(:external_note_id => 'NEWNOTE').first.id.should == note_version.note_id
	end
	it "assigns version = 1 when external_note_id is new" do
		note_version = FactoryGirl.create( :note_version, external_note_id: 'FIRSTVERSION' )
  		note_version.should be_valid
		note_version.version.should == 1
	end
	it "assigns an incremented version number when external_note_id is reused" do
		note_version1 = FactoryGirl.create( :note_version, external_note_id: 'INCREMENTSTVERSION' )
		note_version2 = FactoryGirl.create( :note_version, external_note_id: 'INCREMENTSTVERSION' )
  		note_version2.should be_valid
		note_version2.version.should == 2
	end
end
