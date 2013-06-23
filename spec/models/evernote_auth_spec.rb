# encoding: utf-8

describe EvernoteAuth do

  before do
    @evernote_auth = FactoryGirl.build_stubbed(:evernote_auth)
  end

  subject { @evernote_auth }

  it { should be_valid }
  it { should respond_to(:auth) }

  it { should_not allow_mass_assignment_of(:auth) }

  it { should have_many(:evernote_notes) }
end
