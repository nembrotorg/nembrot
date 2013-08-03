# encoding: utf-8

describe CitationsHelper do

  before do
    @book = FactoryGirl.create(:book)
  end

  describe '#main_details' do
    it 'returns a string containing book details' do
      main_details(@book).should ==  "#{ @book.author }, <cite>#{ @book.title }</cite>. #{ @book.published_city }: #{ @book.publisher } #{ @book.published_date.year }."
    end

    context 'when city is not present' do
      before { @book.published_city = nil }
      it 'adjusts the punctuation' do
        main_details(@book).should ==  "#{ @book.author }, <cite>#{ @book.title }</cite>. #{ @book.publisher } #{ @book.published_date.year }."
      end
    end
  end

  describe '#contributors' do
    it 'returns a string containing all the contributors' do
      contributors(@book).should ==  I18n.t('citation.book.translator_editor_introducer.true_true_true',
                                            translator: @book.translator,
                                            editor: @book.editor,
                                            introducer: @book.introducer)
    end

    context 'when a book has no translator' do
      before { @book.translator = nil }
      it 'adjusts the punctuation' do
        contributors(@book).should ==  I18n.t('citation.book.translator_editor_introducer.false_true_true',
                                              translator: @book.translator,
                                              editor: @book.editor,
                                              introducer: @book.introducer)
      end
    end

    context 'when a book has no extra contributors' do
      before do
        @book.translator = nil
        @book.editor = nil
        @book.introducer = nil
      end
      it 'returns nil' do
        contributors(@book).should == nil
      end
    end
  end

  describe '#classification' do
    context 'when no classification data is available' do
      before do
        @book.translator = nil
        @book.editor = nil
        @book.introducer = nil
      end
      it 'returns just the ISBNs' do
        classification(@book).should == "ISBN: #{ [@book.isbn_10, @book.isbn_13].compact.join(', ') }."
      end
    end
  end

  describe '#links' do
    context 'when no links are available' do
      before do
        @book.isbn_13 = nil
        @book.google_books_id = nil
        @book.library_thing_id = nil
        @book.open_library_id = nil
      end
      it 'returns nil' do
        links(@book).should == ''
      end
    end
  end
end
