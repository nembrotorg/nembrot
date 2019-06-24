class Ability
  include CanCan::Ability

  def initialize(current_user)
    current_user ||= User.new # guest user (not logged in)

    if current_user.admin?
      can :manage, :all
    elsif !current_user.confirmed_at.nil? # REVIEW: See http://stackoverflow.com/questions/17126490/devise-user-signed-in-not-accessible-from-cancan-ability-model
      can :read, :all
      can :menu, User
    else
      can :read, :all
      can :menu, User
      can :reconnect_prompt, User
    end
  end
end
