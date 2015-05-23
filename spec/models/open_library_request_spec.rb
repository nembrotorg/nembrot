# encoding: utf-8

RSpec.describe OpenLibraryRequest do
  context 'when a book is found:' do
    before do
      @open_library_book = OpenLibraryRequest.new('0804720991')
    end

    subject { @open_library_book.metadata }

    its (['author']) { should == 'Friedrich A. Kittler' }
    its (['dewey_decimal']) { should == nil }
    its (['lcc_number']) { should == nil }
    its (['library_thing_id']) { should == '430888' }
    its (['open_library_id']) { should == '212450' }
    its (['page_count']) { should == 459 }
    its (['publisher']) { should == 'Stanford University Press' }
    its (['title']) { should == 'Discourse Networks, 1800-1900' }
  end

  context 'when a book is not found:' do
    before do
      @open_library_book = OpenLibraryRequest.new('INVALID_ISBN')
    end

    subject { @open_library_book }

    its (:metadata) { should == nil }
  end
end
