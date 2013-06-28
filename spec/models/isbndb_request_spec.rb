# encoding: utf-8

describe IsbndbRequest do

  context 'when a book is found:' do
    before do
      VCR.use_cassette('model/isbndb') do
        @isbndb_book = IsbndbRequest.new('0804720991')
      end
    end

    subject { @isbndb_book.metadata }

    its (['dewey_decimal']) { should == '830.9357' }
    its (['isbn_10']) { should == '0804720991' }
    its (['isbn_13']) { should == '9780804720991' }
    its (['lcc_number']) { should == '' }
    its (['published_city']) { should == 'Stanford, Calif.' }
    its (['published_date']) { should == 'c1990' }
    its (['publisher']) { should == 'Stanford University Press' }
    its (['title']) { should == 'Discourse Networks 1800/1900' }
  end

  context 'when a book is not found:' do
    before do
      VCR.use_cassette('model/isbndb_nil') do
        @isbndb_book_nil = IsbndbRequest.new('INVALID_ISBN')
      end
    end

    subject { @isbndb_book_nil }

    its (:metadata) { should == nil }
  end
end