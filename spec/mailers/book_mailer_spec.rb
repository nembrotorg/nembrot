# encoding: utf-8

describe BookMailer do
  describe 'missing_metadata' do
    let(:book) { FactoryGirl.create(:book) }
    let(:mail) { BookMailer.missing_metadata(book) }

    it 'renders the receiver email' do
      expect(mail.to).to eq([Setting['advanced.admin_email']])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([Setting['advanced.admin_email']])
    end

    it 'assigns @name' do
      expect(mail.body.encoded).to match(Setting['advanced.admin_name'])
    end

    it 'includes book details in the subject' do
      expect(mail.subject).to match(book.isbn)
      expect(mail.subject).to match(book.author)
      expect(mail.subject).to match(book.title)
      expect(mail.subject).to match(book.published_date.year.to_s)
    end

    it 'includes book details in the body' do
      expect(mail.body.encoded).to match(book.isbn)
      expect(mail.body.encoded).to match(book.author)
      expect(mail.body.encoded).to match(book.title)
      expect(mail.body.encoded).to match(book.published_date.year.to_s)
    end
  end
end
