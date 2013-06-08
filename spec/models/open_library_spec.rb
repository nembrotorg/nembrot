# encoding: utf-8

describe OpenLibrary do

  context 'when a book is found:' do
    before do
      VCR.use_cassette('model/open_library', decode_compressed_response: true) do
        @open_library_book = OpenLibrary.new('0394510526')
      end
    end

    subject { @open_library_book }

    its (:isbn) { should == '0394510526' }
    its (:title) { should == 'The man without qualities' }
    its (:author) { should == 'Robert Musil' }
    its (:isbn_10) { should == '0394510526' }
    its (:page_count) { should == 1774 }
    its (:publisher) { should == 'A.A. Knopf' }
    its (:library_thing_id) { should == '36097' }
    its (:open_library_id) { should == '850794' }
  end

  context 'when a book is not found:' do
    before do
      VCR.use_cassette('model/open_library_nil', decode_compressed_response: true) do
        @open_library_book = OpenLibrary.new('INVALID_ISBN')
      end
    end

    subject { @open_library_book }

    its (:response) { should == nil }
    its (:title) { should == nil }
    its (:author) { should == nil }
    its (:isbn_10) { should == nil }
    its (:page_count) { should == nil }
    its (:publisher) { should == nil }
    its (:library_thing_id) { should == nil }
    its (:open_library_id) { should == nil }
  end
end
