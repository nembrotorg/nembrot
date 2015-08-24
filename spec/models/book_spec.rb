# encoding: utf-8

RSpec.describe Book do
  before { @book = FactoryGirl.build(:book) }
  subject { @book }

  it { is_expected.to respond_to(:author) }
  it { is_expected.to respond_to(:author_or_editor) }
  it { is_expected.to respond_to(:dewey_decimal) }
  it { is_expected.to respond_to(:dirty) }
  it { is_expected.to respond_to(:editor) }
  it { is_expected.to respond_to(:google_books_embeddable) }
  it { is_expected.to respond_to(:google_books_id) }
  it { is_expected.to respond_to(:introducer) }
  it { is_expected.to respond_to(:isbn) }
  it { is_expected.to respond_to(:isbn_10) }
  it { is_expected.to respond_to(:isbn_13) }
  it { is_expected.to respond_to(:lang) }
  it { is_expected.to respond_to(:lcc_number) }
  it { is_expected.to respond_to(:library_thing_id) }
  it { is_expected.to respond_to(:open_library_id) }
  it { is_expected.to respond_to(:page_count) }
  it { is_expected.to respond_to(:published_city) }
  it { is_expected.to respond_to(:published_date) }
  it { is_expected.to respond_to(:publisher) }
  it { is_expected.to respond_to(:slug) }
  it { is_expected.to respond_to(:tag) }
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:translator) }

  it { is_expected.to have_and_belong_to_many(:notes) }

  describe '.grab_isbns' do
    it 'adds dirty books from an isbn inside a block of text' do
      expect(SyncBookJob).to receive(:perform_later).twice
      Book.grab_isbns('Body text (0804720991, 9780804720991) and more text.')
    end

    context 'when the isbn numbers are not valid (invalid check digits)' do
      before { Book.grab_isbns('Body text (0804720990, 9780804720990) and more text.') }
      it 'does not add books' do
        expect(Book.where(isbn_10: '0804720990').exists?).to be_falsey
        expect(Book.where(isbn_13: '9780804720990').exists?).to be_falsey
      end
    end
  end

  describe '.add_task' do
    it 'adds a dirty book when given an isbn' do
      expect(SyncBookJob).to receive(:perform_later).once
      Book.add_task('0804720991')
    end
  end

  def book_is_updated?
    expect(@book.author).to eq('Friedrich A. Kittler')
    expect(@book.dewey_decimal).to eq('830.9357')
    expect(@book.dimensions).to eq(nil)
    expect(@book.dirty).to eq(false)
    expect(@book.editor).to eq(nil)
    expect(@book.format).to eq(nil)
    expect(@book.full_text_url).to eq(nil)
    expect(@book.google_books_embeddable).to eq(true)
    expect(@book.google_books_id).to eq('nRo0Pk8djjoC')
    expect(@book.introducer).to eq(nil)
    expect(@book.isbn_10).to eq('0804720991')
    expect(@book.isbn_13).to eq('9780804720991')
    expect(@book.lang).to eq('en')
    expect(@book.lcc_number).to eq('')
    expect(@book.library_thing_id).to eq('430888')
    expect(@book.open_library_id).to eq('212450')
    expect(@book.page_count).to eq(459)
    expect(@book.published_city).to eq('Stanford, Calif.')
    expect(@book.published_date.year).to eq(1990)
    expect(@book.publisher).to eq('Stanford University Press')
    expect(@book.slug).to eq('kittler-1990')
    expect(@book.tag).to eq('Kittler 1990')
    expect(@book.title).to eq('Discourse Networks, 1800-1900')
    expect(@book.translator).to eq(nil)
    expect(@book.weight).to eq(nil)
  end

  describe '#populate!' do
    before do
      @book = Book.new(isbn_10: '0804720991')
      @book.populate!
    end
    it 'fetches metadata from four APIs' do
      book_is_updated?
    end
  end

  describe '#tag' do
    it 'creates a tag from author surname and published date' do
      @book.save!
      expect(@book.tag).to eq("#{ @book.author_surname } #{ @book.published_date.year }")
    end
  end

  describe '#slug' do
    it 'should create a slug by parameterizing the tag' do
      @book.save!
      expect(@book.slug).to eq(@book.tag.parameterize)
    end
  end

  describe '#isbn' do
    context 'when isbn_10 is nil' do
      before { @book.update_attributes(isbn_10: nil) }
      it 'returns isbn_13 as isbn' do
        expect(@book.isbn).to eq(@book.isbn_13)
      end
    end
    context 'when isbn_13 is nil' do
      before { @book.update_attributes(isbn_13: nil) }
      it 'returns isbn_10 as isbn' do
        expect(@book.isbn).to eq(@book.isbn_10)
      end
    end
  end

  describe '#short_title' do
    before { @book.update_attributes(title: 'Short Title: Long Title') }
    it 'returns the title without any subtitle' do
      expect(@book.short_title).to eq('Short Title')
    end
  end

  describe '#author_surname' do
    before { @book.update_attributes(author: 'Name Surname') }
    it 'parses author name into name and surname' do
      expect(@book.author_surname).to eq('Surname')
    end
  end

  describe '#headline' do
    before { @book.update_attributes(author: 'Name Surname', title: 'Short Title: Long Title') }
    it 'returns author and short book title' do
      expect(@book.headline).to eq('Surname: <span class="book">Short Title </span>')
    end
  end

  describe '#editor' do
    before { @book.update_attributes(author: nil, editor: 'Name2 Surname2', title: 'Short Title: Long Title') }
    it 'returns editor when author is nil' do
      expect(@book.author_or_editor).to eq("Name2 Surname2 #{ I18n.t('books.show.editor_short') }")
      expect(@book.author_surname).to eq("Surname2 #{ I18n.t('books.show.editor_short') }")
      expect(@book.headline).to eq("Surname2 #{ I18n.t('books.show.editor_short') }: <span class=\"book\">Short Title </span>")
    end
  end
end
