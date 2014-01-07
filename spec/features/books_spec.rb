# encoding: utf-8

describe 'Books' do

  before do
    @user = FactoryGirl.create(:user)
    visit new_user_session_path
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'changeme'
    click_button('Sign in')
    @book = FactoryGirl.create(:book)
    @note = FactoryGirl.create(:note, books: [@book], is_citation: true, body: 'Note text.')
    @citation = FactoryGirl.create(:note, books: [@book], is_citation: true, body: "{quote:Text. -- (#{ @book.tag }), p. 1}")
  end

  describe 'admin page' do
    before do
      visit '/bibliography/admin/editable'
    end
    it 'has the title' do
      page.should have_css('h1', text: I18n.t('books.admin.title', mode: 'Editable'))
    end
    it 'has a link to the book' do
      page.should have_text(@book.title)
      page.should have_text(@book.author)
      page.should have_selector("a[href='#{ edit_book_path(@book.id) }']")
    end
  end

  describe 'index page' do
    before do
      visit books_path
    end
    it 'has the title Bibliography' do
      page.should have_css('h1', text: I18n.t('books.index.title'))
    end
    it 'has a link to the book' do
      page.should have_content(ActionController::Base.helpers.strip_tags(@book.headline))
      page.should have_css("a[href='#{ book_path(@book.slug) }']")
    end
  end

  describe 'show page' do
    before do
      visit book_path(@book.slug)
    end
    specify { page.should have_content(@book.title) }
    specify { page.should have_content(@book.author) }
    specify { page.should have_content(@book.translator) }
    specify { page.should have_content(@book.editor) }
    specify { page.should have_content(@book.introducer) }
    specify { page.should have_content(@citation.headline) }

    it 'has a link to the citation' do
      page.should have_content(ActionController::Base.helpers.strip_tags(@book.headline))
      # pending "page.should have_selector(\"a[href='#{ note_or_feature_path(@note) }']\") FIXME: Citation is being shown as a note"
      # pending "page.should have_selector(\"a[href='#{ citation_path(@citation) }']\") FIXME: Citation is being shown as a note"
    end
  end

  describe 'edit page' do
    before do
      visit edit_book_path(@book.id)
    end
    it 'can be updated' do
      fill_in 'Author', with: 'New Author'
      click_button('Save')
      save_and_open_page
      page.should have_content(I18n.t('books.edit.success', title: @book.title))
      @book.reload
      @book.author.should eq('New Author')
    end
    it 'rejects invalid changes' do
      fill_in 'ISBN 10', with: ''
      fill_in 'ISBN 13', with: ''
      click_button('Save')
      page.should have_content(I18n.t('books.edit.failure'))
      @book.reload
      @book.isbn_10.should_not eq('')
      @book.isbn_13.should_not eq('')
    end
  end
end
