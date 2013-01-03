require 'spec_helper'
 
describe CloudServiceMailer do
  describe 'auth_not_found' do
    let(:provider) { 'PROVIDER01' }
    let(:mail) { CloudServiceMailer.auth_not_found(provider) }
 
    it 'renders the subject' do
      mail.subject.should == I18n.t('auth.email.subject', :provider => provider.titlecase)
    end
 
    it 'renders the receiver email' do
      mail.to.should == [Settings.monitoring.email]
    end
 
    it 'renders the sender email' do
      mail.from.should == [Settings.admin.email]
    end
 
    it 'assigns @name' do
      mail.body.encoded.should match(Settings.monitoring.name)
    end
 
    it 'assigns @confirmation_url' do
      mail.body.encoded.should match(Settings.host + '/auth/PROVIDER01')
    end
  end
end