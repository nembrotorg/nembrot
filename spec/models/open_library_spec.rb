# encoding: utf-8

describe OpenLibrary do

  context 'when a book is found:' do
    before do
      VCR.use_cassette('model/open_library') do
        @open_library_book = OpenLibrary.new('0804720991')
      end
    end

    subject { @open_library_book }

    its (:author) { should == 'Friedrich A. Kittler' }
    its (:dewey_decimal) { should == nil }
    its (:isbn) { should == '0804720991' }
    its (:lcc_number) { should == nil }
    its (:library_thing_id) { should == '430888' }
    its (:open_library_id) { should == '212450' }
    its (:page_count) { should == 459 }
    its (:publisher) { should == 'Stanford University press' }
    its (:title) { should == 'Discourse networks, 1800-1900' }

  end

  context 'when a book is not found:' do
    before do
      VCR.use_cassette('model/open_library_nil') do
        @open_library_book = OpenLibrary.new('INVALID_ISBN')
      end
    end

    subject { @open_library_book }

    its (:author) { should == nil }
    its (:dewey_decimal) { should == nil }
    its (:lcc_number) { should == nil }
    its (:library_thing_id) { should == nil }
    its (:open_library_id) { should == nil }
    its (:page_count) { should == nil }
    its (:publisher) { should == nil }
    its (:response) { should == nil }
    its (:title) { should == nil }
  end
end
