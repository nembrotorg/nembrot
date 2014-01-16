# encoding: utf-8

describe BookMailer do
  describe 'missing_metadata' do
    let(:book) { FactoryGirl.create(:book) }
    let(:mail) { BookMailer.missing_metadata(book) }

    it 'renders the receiver email' do
      mail.to.should == [Setting['advanced.admin_email']]
    end

    it 'renders the sender email' do
      mail.from.should == [Setting['advanced.admin_email']]
    end

    it 'assigns @name' do
      mail.body.encoded.should match(Setting['advanced.admin_name'])
    end

    it 'includes book details in the subject' do
      mail.subject.should match(book.isbn)
      mail.subject.should match(book.author)
      mail.subject.should match(book.title)
      mail.subject.should match(book.published_date.year.to_s)
    end

    it 'includes book details in the body' do
      mail.body.encoded.should match(book.isbn)
      mail.body.encoded.should match(book.author)
      mail.body.encoded.should match(book.title)
      mail.body.encoded.should match(book.published_date.year.to_s)
    end
  end
end
