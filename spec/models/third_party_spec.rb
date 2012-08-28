require 'spec_helper'

describe ThirdParty do

  before {
    @third_party = FactoryGirl.build_stubbed(:third_party)
  }

  subject { @note }

  it { should be_valid }
  it { should respond_to(:name) }

  describe "when name is not present" do
    before { @note.name = nil }
    it { should_not be_valid }
    it { should have(1).error_on(:name) }
  end

  describe "when name is not unique" do
    before { 
      @note0 = FactoryGirl.create(:third_party, :name => 'NOTUNIQUE')
      @note = FactoryGirl.build_stubbed(:third_party, :name => 'NOTUNIQUE')
    }
    it { should_not be_valid }
    it { should have(1).error_on(:name) }
  end

end
