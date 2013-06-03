# encoding: utf-8

describe GoogleBooks do

  before do
    VCR.use_cassette('model/google_books', decode_compressed_response: true) do
      @google_book = GoogleBooks.new('0123456789')
    end
  end

  subject { @google_book }

  its (:title) { should == 'The Man Without Qualities' }
  its (:author) { should == 'Professor Robert Musil' }
  its (:lang) { should == 'en' }
  its (:published_date) { should == '2011-09-16' }
  its (:page_count) { should == 1130 }
  its (:google_books_id) { should == 'EmQ6ygAACAAJ' }

end
