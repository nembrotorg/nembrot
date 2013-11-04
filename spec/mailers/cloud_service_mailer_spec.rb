describe CloudServiceMailer do
  describe 'auth_not_found' do
    let(:provider) { 'PROVIDER01' }
    let(:mail) { CloudServiceMailer.auth_not_found(provider) }
 
    it 'renders the subject' do
      mail.subject.should == I18n.t('auth.email.subject', provider: provider.titlecase)
    end
 
    it 'renders the receiver email' do
      mail.to.should == [Settings.channel.monitoring_email]
    end
 
    it 'renders the sender email' do
      mail.from.should == [Settings.admin_email]
    end
 
    it 'assigns @name' do
      mail.body.encoded.should match(Settings.channel.monitoring_name)
    end
 
    it 'assigns @confirmation_url' do
      mail.body.encoded.should match(Settings.host + '/auth/provider01')
    end
  end
end
