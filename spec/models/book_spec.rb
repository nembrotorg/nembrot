# encoding: utf-8

describe Book do

  before { @book = FactoryGirl.create(:book) }
  subject { @book }

  it { should respond_to(:attempts) }
  it { should respond_to(:author) }
  it { should respond_to(:author_or_editor) }
  it { should respond_to(:dewey_decimal) }
  it { should respond_to(:dirty) }
  it { should respond_to(:editor) }
  it { should respond_to(:google_books_embeddable) }
  it { should respond_to(:google_books_id) }
  it { should respond_to(:introducer) }
  it { should respond_to(:isbn) }
  it { should respond_to(:isbn_10) }
  it { should respond_to(:isbn_13) }
  it { should respond_to(:lang) }
  it { should respond_to(:lcc_number) }
  it { should respond_to(:library_thing_id) }
  it { should respond_to(:open_library_id) }
  it { should respond_to(:page_count) }
  it { should respond_to(:published_city) }
  it { should respond_to(:published_date) }
  it { should respond_to(:publisher) }
  it { should respond_to(:slug) }
  it { should respond_to(:tag) }
  it { should respond_to(:title) }
  it { should respond_to(:translator) }

  it { should have_and_belong_to_many(:notes) }

  describe '.grab_isbns' do
    before { Book.grab_isbns('Body text (0804720991, 9780804720991) and more text.') }
    it 'adds dirty books from an isbn inside a block of text' do
      Book.where(isbn_10: '0804720991', dirty: true).exists?.should eq(true)
      Book.where(isbn_13: '9780804720991', dirty: true).exists?.should eq(true)
    end

    context 'when the isbn numbers are not valid (invalid check digits)' do
      before { Book.grab_isbns('Body text (0804720990, 9780804720990) and more text.') }
      it 'adds dirty books from an isbn inside a block of text' do
        Book.where(isbn_10: '0804720990').exists?.should eq(false)
        Book.where(isbn_13: '9780804720990').exists?.should eq(false)
      end
    end
  end

  describe '.add_task' do
    before { Book.add_task('0804720991') }
    it 'adds a dirty book when given an isbn' do
      Book.where(isbn_10: '0804720991', dirty: true).exists?.should eq(true)
    end
  end

  def book_is_updated?
    @book.author.should                   == 'Friedrich A. Kittler'
    @book.attempts.should                 == 0
    @book.dewey_decimal.should            == '830.9357'
    @book.dimensions.should               == nil
    @book.dirty.should                    == false
    @book.editor.should                   == ''
    @book.format.should                   == nil
    @book.full_text_url.should            == nil
    @book.google_books_embeddable.should  == true
    @book.google_books_id.should          == 'nRo0Pk8djjoC'
    @book.introducer.should               == ''
    @book.isbn_10.should                  == '0804720991'
    @book.isbn_13.should                  == '9780804720991'
    @book.lang.should                     == 'en'
    @book.lcc_number.should               == ''
    @book.library_thing_id.should         == '430888'
    @book.open_library_id.should          == '212450'
    @book.page_count.should               == 459
    @book.published_city.should           == 'Stanford, Calif.'
    @book.published_date.year.should      == 1990
    @book.publisher.should                == 'Stanford University Press'
    @book.slug.should                     == 'kittler-1990'
    @book.tag.should                      == 'Kittler 1990'
    @book.title.should                    == 'Discourse Networks 1800/1900'
    @book.translator.should               == ''
    @book.weight.should                   == nil
  end

  describe '#populate!' do
    before do
      @book = Book.add_task('0804720991')
      @book.populate!
    end
    it 'fetches metadata from four APIs' do
      book_is_updated?
      @book.attempts.should == 0
    end
  end

  describe '#tag' do
    it 'creates a tag from author surname and published date' do
      @book.tag.should == "#{ @book.author_surname } #{ @book.published_date.year }"
    end
  end

  describe '#slug' do
    it 'should create a slug by parameterizing the tag' do
      @book.slug.should == @book.tag.parameterize
    end
  end

  describe '#isbn' do
    context 'when isbn_10 is nil' do
      before { @book.update_attributes(isbn_10: nil) }
      it 'returns isbn_13 as isbn' do
        @book.isbn.should == @book.isbn_13
      end
    end
    context 'when isbn_13 is nil' do
      before { @book.update_attributes(isbn_13: nil) }
      it 'returns isbn_10 as isbn' do
        @book.isbn.should == @book.isbn_10
      end
    end
  end

  describe '#short_title' do
    before { @book.update_attributes(title: 'Short Title: Long Title') }
    it 'returns the title without any subtitle' do
      @book.short_title.should == 'Short Title'
    end
  end

  describe '#author_surname' do
    before { @book.update_attributes(author: 'Name Surname') }
    it 'parses author name into name and surname' do
      @book.author_surname.should == 'Surname'
    end
  end

  describe '#headline' do
    before { @book.update_attributes(author: 'Name Surname', title: 'Short Title: Long Title') }
    it 'returns author and short book title' do
      @book.headline.should == 'Surname: <cite>Short Title</cite>'
    end
  end

  describe '#editor' do
    before { @book.update_attributes(author: nil, editor: 'Name2 Surname2', title: 'Short Title: Long Title') }
    it 'returns editor when author is nil' do
      @book.author_or_editor.should eq("Name2 Surname2 #{ I18n.t('books.show.editor_short') }")
      @book.author_surname.should eq("Surname2 #{ I18n.t('books.show.editor_short') }")
      @book.headline.should eq("Surname2 #{ I18n.t('books.show.editor_short') }: <cite>Short Title</cite>")
    end
  end
end
