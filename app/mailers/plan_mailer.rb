class PlanMailer < ActionMailer::Base
  default from: 'subscriptions@nembrot.com'

  def successful_upgrade(user)
    @first_name = user.first_name
    @last_name = user.last_name
    @email = user.paypal_email
    @plan = user.plan.name

    mail(
      to: "#{ @first_name } #{ @last_name } <#{ @email }>",
      subject: "Upgraded to #{ @plan } user on nembrot.com"
    )
  end

  def downgrade_warning(user)
    @first_name = user.first_name
    @email = user.paypal_email
    @plan = user.plan.name
    @free_plan = Plan.free.name

    mail(
      to: "#{ @first_name } #{ @last_name } <#{ @email }>",
      subject: "Your subscription payment for nembrot.com #{ @plan } has not been received"
    )
  end

  def downgrade(user)
    @first_name = user.first_name
    @email = user.paypal_email
    @plan = user.plan.name
    @free_plan = Plan.free.name
    @max_free_channels = Plan.free.max_channels

    mail(
      to: "#{ @first_name } #{ @last_name } <#{ @email }>",
      subject: "Your nembrot.com account has been reset to #{ @free_plan }"
    )
  end
end
