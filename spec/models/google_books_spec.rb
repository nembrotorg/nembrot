# encoding: utf-8

describe GoogleBooks do

  context 'when a book is found' do
    before do
      VCR.use_cassette('model/google_books', decode_compressed_response: true) do
        @google_books_book = GoogleBooks.new('0804720991')
      end
    end

    subject { @google_books_book }

    its (:author) { should == 'Friedrich A. Kittler' }
    its (:google_books_embeddable) { should == true }
    its (:google_books_id) { should == 'nRo0Pk8djjoC' }
    its (:isbn) { should == '0804720991' }
    its (:lang) { should == 'en' }
    its (:page_count) { should == 459 }
    its (:published_date) { should == '1992-08-01' }
    its (:title) { should == 'Discourse Networks 1800/1900' }
  end

  context 'when a book is not found' do
    before do
      VCR.use_cassette('model/google_books_nil', decode_compressed_response: true) do
        @google_books_book_nil = GoogleBooks.new('INVALID_ISBN')
      end
    end

    subject { @google_books_book_nil }

    its (:author) { should == nil }
    its (:google_books_embeddable) { should == nil }
    its (:google_books_id) { should == nil }
    its (:lang) { should == nil }
    its (:page_count) { should == nil }
    its (:published_date) { should == nil }
    its (:response) { should == nil }
    its (:title) { should == nil }
  end
end
