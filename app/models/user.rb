# See http://www.codebeerstartups.com/2013/10/social-login-integration-with-all-the-popular-social-networks-in-ruby-on-rails/

class User < ActiveRecord::Base

  devise :confirmable, :database_authenticatable, :recoverable, :registerable, :rememberable, :trackable, :validatable,
         :omniauthable

  validates_presence_of :email

  has_many :authorizations, dependent: :destroy

  acts_as_commontator

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
      # Wouldn't this find any other user with blank email?????
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
    #  If secret provided matches those in settings, set user role to secret
    if auth.provider == 'evernote'
      authorization.extra = auth.extra
      authorization.key = auth.extra.access_token.consumer.key
      user.role = 'admin' if auth.extra.access_token.consumer.secret.to_s == Secret.auth.evernote.secret
    end

    user.skip_confirmation!
    user.save!(validate: false) # Allow users to not have an email address

    authorization.nickname = auth.info.nickname
    authorization.user_id = user.id
    authorization.save!
    user
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
end
