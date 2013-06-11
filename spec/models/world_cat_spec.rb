# encoding: utf-8

describe WorldCat do

  context 'when a book is found:' do
    before do
      VCR.use_cassette('model/world_cat', decode_compressed_response: true) do
        @world_cat_book = WorldCat.new('0804720991')
      end
    end

    subject { @world_cat_book }

    its (:editor) { should == '' }
    its (:introducer) { should == '' }
    its (:isbn) { should == '0804720991' }
    its (:published_date) { should == '1-1-1990' }
    its (:publisher) { should == 'Stanford University Press' }
    its (:translator) { should == '' }
  end

  context 'when a book is not found:' do
    before do
      VCR.use_cassette('model/world_cat_nil', decode_compressed_response: true) do
        @world_cat_book_nil = WorldCat.new('INVALID_ISBN')
      end
    end

    subject { @world_cat_book_nil }

    its (:editor) { should == nil }
    its (:introducer) { should == nil }
    its (:published_date) { should == nil }
    its (:publisher) { should == nil }
    its (:response) { should == nil }
    its (:translator) { should == nil }
  end
end
