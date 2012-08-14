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

end
