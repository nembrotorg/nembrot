require 'spec_helper'

describe CloudService do

  before {
    @cloud_service = FactoryGirl.build_stubbed(:cloud_service)
  }

  subject { @cloud_service }

  it { should be_valid }
  it { should respond_to(:name) }

  describe "when name is not present" do
    before { @cloud_service.name = nil }
    it { should_not be_valid }
    it { should have(1).error_on(:name) }
  end

  describe "when name is not unique" do
    before { 
      @cloud_service0 = FactoryGirl.create(:cloud_service, :name => 'NOTUNIQUE')
      @cloud_service = FactoryGirl.build_stubbed(:cloud_service, :name => 'NOTUNIQUE')
    }
    it { should_not be_valid }
    it { should have(1).error_on(:name) }
  end

end
