describe Book do

  before { @book = FactoryGirl.create(:book) }
  subject { @book }

  it { should respond_to(:title) }
  it { should respond_to(:author) }
  it { should respond_to(:translator) }
  it { should respond_to(:introducer) }
  it { should respond_to(:editor) }
  it { should respond_to(:lang) }
  it { should respond_to(:published_date) }
  it { should respond_to(:published_city) }
  it { should respond_to(:publisher) }
  it { should respond_to(:isbn_10) }
  it { should respond_to(:isbn_13) }
  it { should respond_to(:page_count) }
  it { should respond_to(:google_books_id) }
  it { should respond_to(:tag) }
  it { should respond_to(:dirty) }
  it { should respond_to(:attempts) }
  it { should respond_to(:library_thing_id) }
  it { should respond_to(:open_library_id) }

  it { should have_and_belong_to_many(:notes) }

  describe 'grab_isbns' do
    before { Book.grab_isbns('Referencing book Title by Name Surname (0123456789, 0123456780, 0123456789012) and more text.') }
    it 'should add dirty books from an isbn inside a block of text' do
      Book.where(isbn_10: '0123456789', dirty: true).exists?.should eq(true)
      Book.where(isbn_10: '0123456780', dirty: true).exists?.should eq(true)
      Book.where(isbn_13: '0123456789012', dirty: true).exists?.should eq(true)
    end
  end

  describe 'add_task' do
    before { Book.add_task('0123456789') }
    it 'should add a dirty book when given an isbn' do
      Book.where(isbn_10: '0123456789', dirty: true).exists?.should eq(true)
    end
  end

  describe 'tag' do
    it 'should create a tag from author surname and published date' do
      @book.tag.should == "#{ @book.author_surname } #{ @book.published_date.year }"
    end
  end

  describe 'slug' do
    it 'should create a slug by parameterizing the tag' do
      @book.slug.should == @book.tag.parameterize
    end
  end

  describe 'isbn' do
    before { @book.update_attributes(isbn_10: nil) }
    it 'should return isbn_13 as isbn when isbn_10 is nil' do
      @book.isbn.should == @book.isbn_13
    end
  end

  describe 'isbn' do
    before { @book.update_attributes(isbn_13: nil) }
    it 'should return isbn_10 as isbn when isbn_13 is nil' do
      @book.isbn.should == @book.isbn_10
    end
  end

  describe 'short title' do
    before { @book.update_attributes(title: 'Short Title: Long Title') }
    it 'should return the title without any subtitle' do
      @book.short_title.should == 'Short Title'
    end
  end

  describe 'author_surname' do
    before { @book.update_attributes(author: 'Name Surname') }
    it 'should parse author name into name and surname' do
      @book.author_surname.should == 'Surname'
    end
  end

  describe 'headline' do
    before { @book.update_attributes(author: 'Name Surname', title: 'Short Title: Long Title') }
    it 'should returns author and short book title' do
      @book.headline.should == 'Surname: Short Title'
    end
  end

  describe 'editor' do
    before { @book.update_attributes(author: nil, editor: 'Name2 Surname2', title: 'Short Title: Long Title') }
    it 'should return editor when author is nil' do
      @book.author_or_editor.should == "Name2 Surname2 #{ I18n.t('books.editor_short') }"
      @book.author_surname.should == "Surname2 #{ I18n.t('books.editor_short') }"
      @book.headline.should == "Surname2 #{ I18n.t('books.editor_short') }: Short Title"
    end
  end
end
