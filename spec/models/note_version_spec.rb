require 'spec_helper'

describe NoteVersion do
	it "has a valid factory" do
		FactoryGirl.create( :note_version ).should be_valid
	end
	# it "is invalid without an note_id" do
	# 	FactoryGirl.build( :note_version, note_id: nil).should_not be_valid
	# end
	it "is invalid without a title" do
		FactoryGirl.build( :note_version, title: nil).should_not be_valid
	end
	it "is invalid without a body" do
		FactoryGirl.build( :note_version, body: nil).should_not be_valid
	end
	it "is invalid without a version" do
		FactoryGirl.build( :note_version, version: nil).should_not be_valid
	end
end
