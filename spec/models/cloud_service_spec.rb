describe CloudService do

  before {
    @cloud_service = FactoryGirl.build_stubbed(:cloud_service)
  }

  subject { @cloud_service }

  it { should be_valid }
  it { should respond_to(:name) }
  it { should respond_to(:auth) }

  it { should_not allow_mass_assignment_of(:auth) }

  it { should have_many(:cloud_notes) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
