require 'spec_helper'

describe Note do
	it "has a valid factory" do
		FactoryGirl.create( :note ).should be_valid
	end
	it "is invalid without an external_note_id" do
		FactoryGirl.build( :note, external_note_id: nil).should_not be_valid
	end
end
