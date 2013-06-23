# encoding: utf-8

describe EvernoteAuthsController do

  describe 'GET #auth_callback' do
  
    before { get :auth_callback, :provider => 'evernote' }
    pending "it { should respond_with(:redirect) }"
  end

  describe 'GET #auth_failure' do
  
    before { get :auth_failure, :provider => 'evernote' }
    pending "it { should respond_with(:redirect) }"
  end
end
