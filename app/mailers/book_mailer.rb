class BookMailer < ActionMailer::Base
  default from: Constant.admin_email

  def metadata_missing(book)
    @isbn = book.isbn
    @author = book.author
    @title = book.title
    @published_date = book.published_date
    @id = book.id

    mail(
      to: Setting['channel.monitoring_email'],
      subject: I18n.t('books.sync.metadata_missing.email.subject',
                         isbn: @isbn, details: "#{ @author } | #{ @title } | #{ @published_date }"),
      host: Constant.host
    )
  end
end
