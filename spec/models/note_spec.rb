require 'spec_helper'

describe Note do

  before {
    @note = FactoryGirl.build_stubbed(:note)
  }

  subject { @note }

  it { should be_valid }
  it { should respond_to(:external_identifier) }

  describe "when external_identifier is not present" do
    before { @note.external_identifier = nil }
    it { should_not be_valid }
  end

  describe "when external_identifier is not unique" do
    before { 
      @note0 = FactoryGirl.create(:note, :external_identifier => 'NOTUNIQUE')
      @note = FactoryGirl.build_stubbed(:note, :external_identifier => 'NOTUNIQUE')
    }
    it { should_not be_valid }
    it { should have(1).error_on( :external_identifier ) }
  end

end
