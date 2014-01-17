# encoding: utf-8

describe 'Links' do

  before do
    @user = FactoryGirl.create(:user)
    @current_channel = FactoryGirl.create(:channel, user: @user)
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
    specify { page.should have_css('h1', text: I18n.t('links.admin.title')) }
    specify { page.should have_text(@link.title) }
    specify { page.should have_text(@link.url) }
    specify { page.should have_text(@link.channel) }
    specify { page.should have_selector("a[href='#{ edit_link_path(@current_channel, @link.id) }']") }
  end

  describe 'index page' do
    before do
      visit links_path
    end
    specify { page.should have_css('h1', text: I18n.t('links.index.title')) }
    specify { page.should have_selector("a[href='#{ link_path(@current_channel, @link) }']") }
  end

  describe 'show_channel page' do
    before do
      visit link_path(@current_channel, @link.channel)
    end
    specify { page.should have_selector("a[href='#{ note_path(@current_channel, @note) }']") }
  end

  describe 'edit page' do
    before do
      visit edit_link_path(@current_channel, @link.id)
    end
    it 'can be updated' do
      fill_in 'Title', with: 'New Title'
      click_button('Save')
      page.should have_content I18n.t('links.edit.success', channel: @link.channel)
      @link.reload
      @link.title.should eq('New Title')
    end
    it 'rejects invalid changes' do
      fill_in 'link[url]', with: ''
      click_button('Save')
      page.should have_content I18n.t('links.edit.failure')
      @link.reload
      @link.url.should_not eq('')
    end
  end
end
