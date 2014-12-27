# encoding: utf-8

describe 'Links' do

  before do
    @user = FactoryGirl.create(:user)
    visit new_user_session_path
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'changeme'
    click_button('Sign in')
    @note = FactoryGirl.create(:note)
    @link = FactoryGirl.create(:link)
    @link.notes << @note
  end

  describe 'admin page' do
    before do
      visit links_admin_path
    end
    specify { expect(page).to have_css('h1', text: I18n.t('links.admin.title')) }
    specify { expect(page).to have_text(@link.title) }
    specify { expect(page).to have_text(@link.url) }
    specify { expect(page).to have_text(@link.channel) }
    specify { expect(page).to have_selector("a[href='#{ edit_link_path(@link.id) }']") }
  end

  describe 'index page' do
    before do
      visit links_path
    end
    specify { expect(page).to have_css('h1', text: I18n.t('links.index.title')) }
    specify { expect(page).to have_selector("a[href='#{ link_path(@link) }']") }
  end

  describe 'show_channel page' do
    before do
      visit link_path(@link.channel)
    end
    specify { expect(page).to have_selector("a[href='#{ note_path(@note) }']") }
  end

  describe 'edit page' do
    before do
      visit edit_link_path(@link.id)
    end
    it 'can be updated' do
      fill_in 'Title', with: 'New Title'
      click_button('Save')
      expect(page).to have_content I18n.t('links.edit.success', channel: @link.channel)
      @link.reload
      expect(@link.title).to eq('New Title')
    end
    it 'rejects invalid changes' do
      fill_in 'link[url]', with: ''
      click_button('Save')
      expect(page).to have_content I18n.t('links.edit.failure')
      @link.reload
      expect(@link.url).not_to eq('')
    end
  end
end
