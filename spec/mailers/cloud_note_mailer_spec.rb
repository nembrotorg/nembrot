# encoding: utf-8

describe CloudNoteMailer do
  describe '.syncdown_note_failed' do
    let(:provider) { 'PROVIDER01' }
    let(:guid) { 'USER01' }
    let(:title) { 'Note 1' }
    let(:username) { 'USER01' }
    let(:mail) { CloudNoteMailer.syncdown_note_failed(provider, guid, title, username, 'failed') }

    it 'renders the subject' do
      expect(mail.subject).to eq(I18n.t('notes.sync.failed.email.subject', provider: provider.titlecase,
                                                                       guid: guid,
                                                                       username: username))
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([Setting['advanced.admin_email']])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([Setting['advanced.admin_email']])
    end

    it 'assigns @name' do
      expect(mail.body.encoded).to match(Setting['advanced.admin_name'])
    end

    it 'assigns @user' do
      expect(mail.body.encoded).to match(username)
    end

    it 'assigns @error class' do
      # Is this needed?
      # pending "mail.body.encoded.should match('ERRORCLASS')"
    end

    it 'assigns @error message' do
      # Is this needed?
      # pending "mail.body.encoded.should match('ERRORMESSAGE')"
    end

    context 'when note is conflicted' do
      # pending 'Tests'
    end
  end
end
