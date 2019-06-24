# encoding: utf-8

RSpec.describe WorldCatRequest do
  context 'when a book is found:' do
    before do
      @world_cat_book = WorldCatRequest.new('0804720991')
    end

    subject { @world_cat_book.metadata }

    describe (['editor']) do
      subject { super().send((['editor'])) }
      it { is_expected.to eq('') }
    end

    describe (['introducer']) do
      subject { super().send((['introducer'])) }
      it { is_expected.to eq('') }
    end

    describe (['published_date']) do
      subject { super().send((['published_date'])) }
      it { is_expected.to eq('1-1-1990') }
    end

    describe (['publisher']) do
      subject { super().send((['publisher'])) }
      it { is_expected.to eq('Stanford University Press') }
    end

    describe (['translator']) do
      subject { super().send((['translator'])) }
      it { is_expected.to eq('') }
    end
  end

  context 'when a book is not found:' do
    before do
      @world_cat_book_nil = WorldCatRequest.new('INVALID_ISBN')
    end

    # TODO: This fails!
    # pending 'its (:metadata) { should == nil }'
  end
end
