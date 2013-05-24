describe GoogleBooks do

  before {
    VCR.use_cassette('model/google_books', :decode_compressed_response => true) do
      @google_book = GoogleBooks.new('0123456789')
    end
  }

  subject { @google_book }

  its (:title) { should == 'The Man Without Qualities' }

end
