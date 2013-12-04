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
    context 'when we are strating from scratch' do
      specify { Pantograph.calculate_after('').should eq('0') }
    end
    context 'when the previous pantograph is one letter long' do
      specify { Pantograph.calculate_after('0').should eq('1') }
    end
    context 'when the previous pantograph is more than one letter long' do
      specify { Pantograph.calculate_after('00').should eq('01') }
    end
    context 'when a digit needs to be shifted' do
      specify { Pantograph.calculate_after('z').should eq('00') }
      specify { Pantograph.calculate_after('0z').should eq('10') }
    end
    context 'when pantograph includes punctuation' do
      specify { Pantograph.calculate_after('.zz').should eq(',00') }
      specify { Pantograph.calculate_after('.zz').should eq(',00') }
      specify { Pantograph.calculate_after('00/').should eq('00#') }
      specify { Pantograph.calculate_after('0//0').should eq('0//1') }
      specify { Pantograph.calculate_after('0%').should eq("0'") }
      specify { Pantograph.calculate_after(".,;:_@!?/#()%'-+= a").should eq(".,;:_@!?/#()%'-+= b") }
    end
    context 'when leading, trailing and multiple spaces should be supressed' do
      specify { Pantograph.calculate_after('0=').should eq('0a') }
      specify { Pantograph.calculate_after('=z').should eq('a0') }
      specify { Pantograph.calculate_after('0 =z').should eq('0 a0') }
    end
    context 'when we have reached the end' do
      specify { Pantograph.calculate_after(Pantograph.last_phrase).should eq(Pantograph.last_phrase) }
    end
  end

  describe '.sequence' do
    # REVIEW: Add test Pantograph.where(body: Pantograph.last_phrase).sequence == Pantograph.total_phrases
    before { Pantograph.body = Pantograph.last_phrase }
    context 'when we have reached the end sequence should be equal to total phrases' do
    end
  end

  describe '.sanitize' do
    specify { Pantograph.sanitize(Constant.pantography.alphabet_escaped).should eq(Pantograph.alphabet) }
  end

  describe '.sanitize' do
    specify { Pantograph.sanitize(Constant.pantography.alphabet_escaped).should eq(Pantograph.alphabet) }
  end

  describe '.previous_pantograph' do
    before { @pantograph.body = '7' }
    its(:previous_pantograph) { should eq('6') }
  end

  describe '.next_pantograph' do
    before { @pantograph.body = '7' }
    its(:next_pantograph) { should eq('8') }
  end

  describe '.previous_escaped' do
    before { @pantograph.body = '0?7' }
    its(:previous_pantograph) { should eq('0?6') }
  end

  describe '.next_escaped' do
    before { @pantograph.body = '0?7' }
    its(:next_pantograph) { should eq('0?8') }
  end

  describe '.previous_path' do
    before { @pantograph.body = '0?7' }
    its(:previous_path) { should eq('/pantography/0%3F6') }
  end

  describe '.next_path' do
    before { @pantograph.body = '0?7' }
    its(:next_path) { should eq('/pantography/0%3F8') }
  end

  describe '.first_path' do
    before { @pantograph.body = '0?7' }
    its(:first_path) { should eq('/pantography/0') }
  end

  describe '.last_path' do
    before { @pantograph.body = '0?7' }
    its(:last_path) { should eq('/pantography/zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz') }
  end

  # describe '.publish_next' do
  #   Pantograph.publish_next.should == ''
  # end

  # describe '.last_by_self_body' do
  #   before do
  #     @pantographer_self = FactoryGirl.create(:pantographer, twitter_user_id: Constant.pantography.twitter_user_id)
  #     @pantographer_other = FactoryGirl.create(:pantographer, twitter_user_id: '1')
  #     @pantograph_by_self = FactoryGirl.create(:pantograph, pantographer_id: @pantographer_self.id)
  #     @pantograph_by_other = FactoryGirl.create(:pantograph, pantographer_id: @pantographer_other.id)
  #   end
  #   Pantograph.last_by_self_body.should == @pantograph_by_self.body
  # end

end
