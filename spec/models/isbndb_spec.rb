# encoding: utf-8

describe Isbndb do

  context 'when a book is found:' do
    before do
      VCR.use_cassette('model/isbndb') do
        # Secret['auth']['isbndb']['api_key'] = 'OBSCURED'
        @isbndb_book = Isbndb.new('0804720991')
      end
    end

    subject { @isbndb_book }

    its (:dewey_decimal) { should == '830.9357' }
    its (:isbn) { should == '0804720991' }
    its (:isbn_10) { should == '0804720991' }
    its (:isbn_13) { should == '9780804720991' }
    its (:lcc_number) { should == '' }
    its (:published_city) { should == 'Stanford, Calif.' }
    its (:published_date) { should == 'c1990' }
    its (:publisher) { should == 'Stanford University Press' }
    its (:title) { should == 'Discourse networks 1800/1900' }
  end

  context 'when a book is not found:' do
    before do
      VCR.use_cassette('model/isbndb_nil') do
        @isbndb_book_nil = Isbndb.new('INVALID_ISBN')
      end
    end

    subject { @isbndb_book_nil }

    its (:dewey_decimal) { should == nil }
    its (:isbn_10) { should == nil }
    its (:isbn_13) { should == nil }
    its (:lcc_number) { should == nil }
    its (:published_city) { should == nil }
    its (:published_date) { should == nil }
    its (:publisher) { should == nil }
    its (:response) { should == nil }
    its (:title) { should == nil }
  end
end