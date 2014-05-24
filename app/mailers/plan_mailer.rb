class PlanMailer < ActionMailer::Base
  default from: 'subscriptions@nembrot.com'

  def successful_upgrade(user)
    @first_name = user.first_name
    @email = user.email
    @plan = user.plan.name

    mail(
      to: @email,
      subject: 'Upgraded to Premium user on nembrot.com'
    )
  end

  def unconfirmed_upgrade(user)
    @first_name = user.first_name
    @email = user.email
    @plan = user.plan.name

    mail(
      to: @email,
      subject: 'Unsuccessful upgrade on nembrot.com'
    )
  end

  def downgrade_warning(user)
    @first_name = user.first_name
    @email = user.email
    @plan = user.plan.name

    mail(
      to: @email,
      subject: 'Your subscription to nembrot.com has not been renewed'
    )
  end

  def downgrade(user)
    @first_name = user.first_name
    @email = user.email
    @plan = user.plan.name

    mail(
      to: @email,
      subject: 'Your nembrot.com account will be reset to Free'
    )
  end
end
