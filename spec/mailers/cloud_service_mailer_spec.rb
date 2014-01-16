describe CloudServiceMailer do
  describe 'auth_not_found' do
    let(:provider) { 'PROVIDER01' }
    let(:mail) { CloudServiceMailer.auth_not_found(provider) }

    it 'renders the subject' do
      mail.subject.should == I18n.t('auth.email.subject', provider: provider.titlecase)
    end

    it 'renders the receiver email' do
      mail.to.should == [Setting['advanced.admin_email']]
    end

    it 'renders the sender email' do
      mail.from.should == [Setting['advanced.admin_email']]
    end

    it 'assigns @name' do
      mail.body.encoded.should match(Setting['advanced.admin_name'])
    end

    it 'assigns @confirmation_url' do
      mail.body.encoded.should match(Constant.host + '/users/auth/provider01')
    end
  end
end
