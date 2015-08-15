class BookMailer < ActionMailer::Base
  default from: NB.admin_email

  def missing_metadata(book)
    @isbn = book.isbn
    @author = book.author
    @title = book.title
    @published_date = book.published_date
    @id = book.id

    mail(
      to: NB.admin_email,
      subject: I18n.t('books.sync.missing_metadata.email.subject',
                      isbn: @isbn, details: "#{ @author } | #{ @title } | #{ @published_date }"),
      host: NB.host
    )
  end
end
