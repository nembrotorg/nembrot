# encoding: utf-8

describe 'Users' do

  before do
    @user = FactoryGirl.create(:user)
  end

  describe 'sign in page' do
    before do
      visit new_user_session_path
    end
    it 'user can sign in' do
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button('Sign in')
      page.should have_text('Signed in successfully.')
    end
    it 'user can sign out' do
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button('Sign in')
      find(:xpath, "//a[@href='/users/sign_out']").click
      page.should have_text('Signed out successfully.')

    end
    context 'when a wrong email is entered' do
      it 'rejects sign-in' do
        fill_in 'Email', with: 'wrong@email.com'
        fill_in 'Password', with: @user.password
        click_button('Sign in')
        page.should have_text('Invalid email or password.')
      end
    end
    context 'when a wrong password is entered' do
      it 'rejects sign-in' do
        fill_in 'Email', with: @user.email
        fill_in 'Password', with: 'worngpassword'
        click_button('Sign in')
        page.should have_text('Invalid email or password.')
      end
    end
  end

  describe 'edit registration page' do
    before do
      visit new_user_session_path
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button('Sign in')
    end
    it 'user can change the password' do
      visit edit_user_registration_path
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: 'newpassword'
      fill_in 'Password confirmation', with: 'newpassword'
      fill_in 'Current password', with: @user.password
      click_button('Edit registration')
      page.should have_text('You updated your account successfully.')
      find(:xpath, "//a[@href='/users/sign_out']").click
      visit new_user_session_path
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: 'newpassword'
      click_button('Sign in')
      page.should have_text('Signed in successfully.')
    end
  end
end
