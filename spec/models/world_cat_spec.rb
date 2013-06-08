# encoding: utf-8

describe WorldCat do

  context 'when a book is found:' do
    before do
      VCR.use_cassette('model/world_cat', decode_compressed_response: true) do
        @world_cat_book = WorldCat.new('0394510526')
      end
    end

    subject { @world_cat_book }

    its (:isbn) { should == '0394510526' }
    its (:publisher) { should == 'A.A. Knopf' }
    its (:published_date) { should == '1-1-1995' }
    its (:translator) { should == 'John Smith' }
    its (:introducer) { should == 'Belinda Smith' }
    its (:editor) { should == 'Cece Smith' }
  end

  context 'when a book is not found:' do
    before do
      VCR.use_cassette('model/world_cat_nil', decode_compressed_response: true) do
        @world_cat_book_nil = WorldCat.new('INVALID_ISBN')
      end
    end

    subject { @world_cat_book_nil }

    its (:response) { should == nil }
    its (:publisher) { should == nil }
    its (:published_date) { should == nil }
    its (:translator) { should == nil }
    its (:introducer) { should == nil }
    its (:editor) { should == nil }
  end
end
