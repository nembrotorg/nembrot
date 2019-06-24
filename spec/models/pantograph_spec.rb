# encoding: utf-8

RSpec.describe Pantograph do
  before do
    @pantograph = FactoryGirl.build_stubbed(:pantograph)
  end

  subject { @pantograph }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to(:text) }
  it { is_expected.to respond_to(:external_created_at) }
  it { is_expected.to respond_to(:tweet_id) }

  it { is_expected.to belong_to(:pantographer) }

  it { is_expected.to validate_presence_of(:text) }
  it { is_expected.to validate_presence_of(:tweet_id) }

  # it { is_expected.to validate_uniqueness_of(:text) }
  # it { is_expected.to validate_uniqueness_of(:tweet_id) }

  describe '#publish_next' do
    before do
      @pantograph = FactoryGirl.create(:pantograph, text: 'a')
    end
    specify { expect(Pantograph.publish_next).to eq('b') }
  end

  describe '.calculate_next' do
    context 'when we are strating from scratch' do
      specify { expect(Pantograph.calculate_after('')).to eq('0') }
    end
    context 'when the previous pantograph is one letter long' do
      specify { expect(Pantograph.calculate_after('0')).to eq('1') }
    end
    context 'when the previous pantograph is more than one letter long' do
      specify { expect(Pantograph.calculate_after('00')).to eq('01') }
    end
    context 'when a digit needs to be shifted' do
      specify { expect(Pantograph.calculate_after('z')).to eq('00') }
      specify { expect(Pantograph.calculate_after('0z')).to eq('10') }
    end
    context 'when pantograph includes punctuation' do
      specify { expect(Pantograph.calculate_after('.zz')).to eq(',00') }
      specify { expect(Pantograph.calculate_after('.zz')).to eq(',00') }
      specify { expect(Pantograph.calculate_after('00/')).to eq('00#') }
      specify { expect(Pantograph.calculate_after('0//0')).to eq('0//1') }
      specify { expect(Pantograph.calculate_after('0%')).to eq("0'") }
      specify { expect(Pantograph.calculate_after(".,;:_@!?/#()%'-+= a")).to eq(".,;:_@!?/#()%'-+= b") }
    end
    context 'when leading, trailing and multiple spaces should be supressed' do
      specify { expect(Pantograph.calculate_after('0=')).to eq('0a') }
      specify { expect(Pantograph.calculate_after('=z')).to eq('a0') }
      specify { expect(Pantograph.calculate_after('0 =z')).to eq('0 a0') }
    end
    context 'when we have reached the end' do
      specify { expect(Pantograph.calculate_after(Pantograph.last_text)).to eq(Pantograph.last_text) }
    end
  end

  describe '.sequence' do
    # REVIEW: Add test Pantograph.where(text: Pantograph.last_text).sequence == Pantograph.total_texts
    before { Pantograph.text = Pantograph.last_text }
    context 'when we have reached the end sequence should be equal to total texts' do
    end
  end

  describe '.sanitize' do
    # specify { expect(Pantograph.sanitize(ENV['pantography_alphabet_escaped'])).to eq(Pantograph.alphabet) }
  end

  describe '.unspamify' do
    specify { expect(Pantograph.unspamify('#hashtag @mention #more @more')).to eq('Hhashtag Amention Hmore Amore') }
  end

  describe '.spamify' do
    specify { expect(Pantograph.spamify('Hhashtag Amention Hmore Amore')).to eq('#hashtag @mention #more @more') }
  end

  describe '.previous_pantograph' do
    before { @pantograph.text = '7' }
    its(:previous_pantograph) { should eq('6') }
  end

  describe '.next_pantograph' do
    before { @pantograph.text = '7' }
    its(:next_pantograph) { should eq('8') }
  end

  describe '.previous_escaped' do
    before { @pantograph.text = '0?7' }
    its(:previous_pantograph) { should eq('0?6') }
  end

  describe '.next_escaped' do
    before { @pantograph.text = '0?7' }
    its(:next_pantograph) { should eq('0?8') }
  end

  describe '.previous_path' do
    before { @pantograph.text = '0?7' }
    its(:previous_path) { should eq('/pantography/0%3F6') }
  end

  describe '.next_path' do
    before { @pantograph.text = '0?7' }
    its(:next_path) { should eq('/pantography/0%3F8') }
  end

  describe '.first_path' do
    before { @pantograph.text = '0?7' }
    its(:first_path) { should eq('/pantography/0') }
  end

  describe '.last_path' do
    before { @pantograph.text = '0?7' }
    its(:last_path) { should eq('/pantography/zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz') }
  end
end
