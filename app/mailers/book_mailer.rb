class BookMailer < ActionMailer::Base
  default from: Settings.admin.email

  def metadata_missing(book)
    @isbn = book.isbn
    @author = book.author
    @title = book.title
    @published_date = book.published_date
    @id = book.id

    mail(
      :to => Settings.monitoring.email,
      :subject => I18n.t('books.sync.failed.metadata_missing.email.subject',
                         isbn: @isbn, details: "#{ @author } | #{ @title } | #{ @published_date }"),
      :host => Settings.host
    )
  end
end
