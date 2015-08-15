RSpec.describe CloudServiceMailer do
  describe 'auth_not_found' do
    let(:provider) { 'PROVIDER01' }
    let(:mail) { CloudServiceMailer.auth_not_found(provider) }

    it 'renders the subject' do
      expect(mail.subject).to eq(I18n.t('auth.email.subject', provider: provider.titlecase))
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([ENV['admin_email']])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([ENV['admin_email']])
    end

    it 'assigns @name' do
      expect(mail.body.encoded).to match(ENV['admin_name'])
    end

    it 'assigns @confirmation_url' do
      expect(mail.body.encoded).to match(ENV['host'] + '/users/auth/provider01')
    end
  end
end
