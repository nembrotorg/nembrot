class Ability
  include CanCan::Ability

  def initialize(current_user)
    current_user ||= User.new # guest user (not logged in)

    if current_user.admin?
      can :manage, :all
    elsif !current_user.confirmed_at.nil? # REVIEW: See http://stackoverflow.com/questions/17126490/devise-user-signed-in-not-accessible-from-cancan-ability-model
      can :read, :all
      can :hash, Theme
      can :show_channel, Link
      can :menu, User
      can :available, Channel
      can :manage, Channel, :user_id => current_user.id
    else
      can :read, :all
      can :hash, Theme
      can :show_channel, Link
      can :menu, User
      can :create, Channel
      can :evernote_notebooks, Channel
      can :available, Channel
      can :choose, Channel
      cannot :read, Channel
    end
  end
end
