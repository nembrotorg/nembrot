# encoding: utf-8

RSpec.describe 'Books' do
  before do
    @user = FactoryGirl.create(:user)
    visit new_user_session_path
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'changeme'
    click_button('Sign in')
    @book = FactoryGirl.create(:book)
    @note = FactoryGirl.create(:note, books: [@book], body: "Note text that mentions #{ @book.tag }.")
    @citation = FactoryGirl.create(:note, books: [@book], content_type: 1, body: "{quote:Citation text. -- (#{ @book.tag }), p. 1}")
  end

  describe 'admin page' do
    before do
      visit '/bibliography/admin/editable'
    end
    it 'has the title' do
      expect(page).to have_css('h1', text: I18n.t('books.admin.title', mode: 'Editable'))
    end
    it 'has a link to the book' do
      expect(page).to have_text(@book.title)
      expect(page).to have_text(@book.author)
      expect(page).to have_selector("a[href='#{ edit_book_path(@book.id) }']")
    end
  end

  describe 'index page' do
    before do
      visit books_path
    end
    it 'has the title Bibliography' do
      expect(page).to have_css('h1', text: I18n.t('books.index.title'))
    end
    it 'has a link to the book' do
      expect(page).to have_content(ActionController::Base.helpers.strip_tags(@book.headline))
      expect(page).to have_css("a[href='#{ book_path(@book.slug) }']")
    end
  end

  describe 'show page' do
    before do
      visit book_path(@book.slug)
    end
    specify { expect(page).to have_content(@book.title) }
    specify { expect(page).to have_content(@book.author) }
    specify { expect(page).to have_content(@book.translator) }
    specify { expect(page).to have_content(@book.editor) }
    specify { expect(page).to have_content(@book.introducer) }

    it 'contains the citation text' do
      expect(page).to have_content('Citation text')
    end

    it 'has a link to the note' do
      expect(page).to have_selector("a[href='#{ note_path(@note) }']")
    end

    it 'has a link to the citation' do
      expect(page).to have_selector("a[href='#{ citation_path(@citation) }']")
    end
  end

  describe 'edit page' do
    before do
      visit edit_book_path(@book.id)
    end
    it 'can be updated' do
      fill_in 'Author', with: 'New Author'
      click_button('Save')
      expect(page).to have_content(I18n.t('books.edit.success', title: @book.title))
      @book.reload
      expect(@book.author).to eq('New Author')
    end
    it 'rejects invalid changes' do
      fill_in 'ISBN 10', with: ''
      fill_in 'ISBN 13', with: ''
      click_button('Save')
      expect(page).to have_content(I18n.t('books.edit.failure'))
      @book.reload
      expect(@book.isbn_10).not_to eq('')
      expect(@book.isbn_13).not_to eq('')
    end
  end
end
