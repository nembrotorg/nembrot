# encoding: utf-8

describe Pantographer do

  before { @pantographer = FactoryGirl.build_stubbed(:pantographer) }

  subject { @pantographer }

  it { should be_valid }
  it { should respond_to(:twitter_screen_name) }
  it { should respond_to(:twitter_real_name) }
  it { should respond_to(:twitter_user_id) }

  it { should have_many(:pantographs) }

  it { should validate_presence_of(:twitter_screen_name) }
  it { should validate_presence_of(:twitter_real_name) }
  it { should validate_presence_of(:twitter_user_id) }

  # FIXME: "Twitter::Error::NotFound"
  pending "it { should validate_uniqueness_of(:twitter_screen_name) }"
  pending "{ should validate_uniqueness_of(:twitter_user_id) }"
end
