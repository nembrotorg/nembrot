require 'spec_helper'

describe CloudNote do

  let(:cloud_service) { FactoryGirl.build_stubbed(:cloud_service) }
  before {
    @cloud_note = FactoryGirl.build_stubbed(:cloud_note, :cloud_service => cloud_service)
  }

  subject { @cloud_note }

  it { should be_valid }
  it { should respond_to(:cloud_note_identifier) }
  it { should respond_to(:note_id) }
  it { should respond_to(:cloud_service_id) }

  its(:cloud_service) { should == cloud_service }

  describe "when cloud_note_identifier is not present" do
    before { @cloud_note.cloud_note_identifier = nil }
    it { should_not be_valid }
    it { should have(1).error_on(:cloud_note_identifier) }
  end

  describe "when note_id is not present" do
    before { @cloud_note.note_id = nil }
    it { should_not be_valid }
    it { should have(1).error_on(:note_id) }
  end

  describe "when cloud_service_id is not present" do
    before { @cloud_note.cloud_service_id = nil }
    it { should_not be_valid }
    it { should have(1).error_on(:cloud_service_id) }
  end
end
