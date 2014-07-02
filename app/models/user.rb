# See http://www.codebeerstartups.com/2013/10/social-login-integration-with-all-the-popular-social-networks-in-ruby-on-rails/

class User < ActiveRecord::Base

  include Upgradable, Downgradable, Tokenable

  devise :confirmable, :database_authenticatable, :recoverable, :registerable, :rememberable, :trackable, :validatable,
         :omniauthable

  # REVIEW: This needs to go in so notes, etc, are destroyed when user delets account
  #  But check what consequences it would have on business notebooks.
  # has_many :notes, dependent: :destroy

  has_many :authorizations, dependent: :destroy
  has_many :channels, dependent: :destroy
  belongs_to :plan

  has_paper_trail
  acts_as_commontator

  validates_presence_of :plan
  # REVIEW: validate uniqueness of tokens, paypal subscriptions, etc

  before_save :update_plan

  def self.new_with_session(params, session)
    if session['devise.user_attributes']
      new(session['devise.user_attributes'], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def self.from_omniauth(auth, current_user)
    authorization = Authorization.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize
    authorization.token = auth.credentials.token
    authorization.secret = auth.credentials.secret

    if authorization.user.blank?
      # REVIEW: Wouldn't this find any other user with blank email?
      user = current_user.nil? ? User.where('email = ?', auth['info']['email']).first_or_initialize : current_user
      user = User.new if user.blank?
    else
      user = authorization.user
    end

    attributes = ['name', 'nickname', 'first_name', 'last_name', 'location', 'email', 'image']

    attributes.each do |attribute|
      # set_unless_blank(user[attribute], auth.info[attribute])
      user[attribute] = auth.info[attribute] unless auth.info[attribute].blank?
    end

    # Save extra so that we can use keys to sync later
    #  If username matches the one in settings, set user role to admin
    if auth.provider == 'evernote'
      authorization.extra = auth.extra
      authorization.key = auth.extra.access_token.consumer.key
      user.role = 'admin' if auth.info.nickname == Secret.auth.evernote.username
    end

    user.token_for_paypal = user.generate_token

    user.skip_confirmation!
    user.save!(validate: false) # Allow users to not have an email address

    authorization.nickname = auth.info.nickname
    authorization.user_id = user.id
    authorization.save!
    user
  end

  def soft_delete
    authorizations.destroy_all
    skip_confirmation!

    update_attributes(
      confirmation_sent_at: nil,
      confirmation_token: nil,
      confirmed_at: nil,
      current_sign_in_ip: nil,
      email: nil,
      encrypted_password: nil,
      first_name: nil,
      image: nil,
      last_name: nil,
      last_sign_in_at: nil,
      last_sign_in_ip: nil,
      location: nil,
      name: "Former User #{ id }",
      nickname: "formeruser#{ id }",
      role: nil,
      unconfirmed_email: nil)
  end

  def public_name
     name || nickname || ''
     # email.gsub(/\@.*/, '').split(/\.|\-/).join(' ').titlecase
  end

  def admin?
    (role == 'admin')
  end

  def valid_password?(password)
    !authorizations.nil? || super(password)
  end

  # http://dev.mensfeld.pl/2013/12/rails-devise-and-remember_me-rememberable-by-default/
  def remember_me
    true
  end

  private

  def update_plan
    self.plan = Plan.free if plan.nil?
  end
end
