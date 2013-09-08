# encoding: utf-8

describe Pantograph do

  before { @pantograph = FactoryGirl.build_stubbed(:pantograph) }

  subject { @pantograph }

  it { should be_valid }
  it { should respond_to(:body) }
  it { should respond_to(:external_created_at) }
  it { should respond_to(:tweet_id) }

  it { should belong_to(:pantographer) }

  it { should validate_presence_of(:body) }
  it { should validate_presence_of(:tweet_id) }

  it { should validate_uniqueness_of(:body) }
  it { should validate_uniqueness_of(:tweet_id) }

  describe '.calculate_next' do
    specify { Pantograph.calculate_after('').should eq('0') }
    specify { Pantograph.calculate_after('0').should eq('1') }
    specify { Pantograph.calculate_after('ab').should eq('ac') }
    specify { Pantograph.calculate_after('z').should eq('00') }
    specify { Pantograph.calculate_after('0=').should eq('0a') }
    specify { Pantograph.calculate_after('0 =').should eq('0 a') }
    specify { Pantograph.calculate_after('.zz').should eq(',00') }
  end

  # describe '.publish_next' do
  #   Pantograph.publish_next.should == ''
  # end

  # describe '.last_by_self_body' do
  #   before do
  #     @pantographer_self = FactoryGirl.create(:pantographer, twitter_user_id: Settings.pantography.twitter_user_id)
  #     @pantographer_other = FactoryGirl.create(:pantographer, twitter_user_id: '1')
  #     @pantograph_by_self = FactoryGirl.create(:pantograph, pantographer_id: @pantographer_self.id)
  #     @pantograph_by_other = FactoryGirl.create(:pantograph, pantographer_id: @pantographer_other.id)
  #   end
  #   Pantograph.last_by_self_body.should == @pantograph_by_self.body
  # end

end
