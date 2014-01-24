class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      can :manage, :all
    elsif !user.confirmed_at.nil? # REVIEW: See http://stackoverflow.com/questions/17126490/devise-user-signed-in-not-accessible-from-cancan-ability-model
      can :read, :all
      can :show_channel, Link
      can :menu, User
      can :available, Channel
      can :manage, Channel, :user_id => user.id
    else
      can :read, :all
      can :show_channel, Link
      can :menu, User
      can :create, Channel
      can :available, Channel
      can :choose, Channel
      cannot :read, Channel
    end
  end
end
