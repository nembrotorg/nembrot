class BookMailer < ActionMailer::Base
  default from: Setting['advanced.admin_email']

  def missing_metadata(book)
    @isbn = book.isbn
    @author = book.author
    @title = book.title
    @published_date = book.published_date
    @id = book.id

    mail(
      to: Setting['advanced.admin_email'],
      subject: I18n.t('books.sync.missing_metadata.email.subject',
                      isbn: @isbn, details: "#{ @author } | #{ @title } | #{ @published_date }"),
      host: Constant.host
    )
  end
end
