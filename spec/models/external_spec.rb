require 'spec_helper'

describe External do

  let(:third_party) { FactoryGirl.build_stubbed(:third_party) }
  before {
    @external = FactoryGirl.build_stubbed(:external, :third_party => third_party)
  }

  subject { @external }

  it { should be_valid }
  it { should respond_to(:external_identifier) }
  it { should respond_to(:note_id) }
  it { should respond_to(:third_party_id) }

  its(:third_party) { should == third_party }

  describe "when external_identifier is not present" do
    before { @external.external_identifier = nil }
    it { should_not be_valid }
    it { should have(1).error_on(:external_identifier) }
  end

  describe "when note_id is not present" do
    before { @external.note_id = nil }
    it { should_not be_valid }
    it { should have(1).error_on(:note_id) }
  end

  describe "when third_party_id is not present" do
    before { @external.third_party_id = nil }
    it { should_not be_valid }
    it { should have(1).error_on(:third_party_id) }
  end
end
