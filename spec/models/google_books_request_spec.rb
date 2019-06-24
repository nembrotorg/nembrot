# encoding: utf-8

RSpec.describe GoogleBooksRequest do
  context 'when a book is found' do
    before do
      @google_books_book = GoogleBooksRequest.new('0804720991')
    end

    subject { @google_books_book.metadata }

    its (['author']) { should == 'Friedrich A. Kittler' }
    its (['google_books_embeddable']) { should == true }
    its (['google_books_id']) { should == 'nRo0Pk8djjoC' }
    its (['lang']) { should == 'en' }
    its (['page_count']) { should == 459 }
    its (['published_date']) { should == '1992' }
    its (['title']) { should == 'Discourse Networks 1800/1900' }
  end

  context 'when a book is not found' do
    before do
      @google_books_book_nil = GoogleBooksRequest.new('INVALID_ISBN')
    end

    subject { @google_books_book_nil }

    its (:metadata) { should == nil }
  end
end
