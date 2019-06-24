# encoding: utf-8

RSpec.describe Pantographer do
  before { @pantographer = FactoryGirl.build_stubbed(:pantographer) }

  subject { @pantographer }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to(:twitter_screen_name) }
  it { is_expected.to respond_to(:twitter_real_name) }
  it { is_expected.to respond_to(:twitter_user_id) }

  it { is_expected.to have_many(:pantographs) }

  it { is_expected.to validate_presence_of(:twitter_screen_name) }
  it { is_expected.to validate_presence_of(:twitter_real_name) }
  it { is_expected.to validate_presence_of(:twitter_user_id) }

  # it { is_expected.to validate_uniqueness_of(:twitter_screen_name) }
  # it { is_expected.to validate_uniqueness_of(:twitter_user_id) }
end
