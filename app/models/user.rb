# See http://www.codebeerstartups.com/2013/10/social-login-integration-with-all-the-popular-social-networks-in-ruby-on-rails/

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  validates_presence_of :email

  has_many :authorizations

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

    authorization = Authorization.where(provider: auth.provider, uid: auth.uid.to_s, token: auth.credentials.token, secret: auth.credentials.secret).first_or_initialize

    if authorization.user.blank?
      user = current_user.nil? ? User.where('email = ?', auth['info']['email']).first : current_user
      user = User.new if user.blank?
    else
      user = authorization.user
    end

    user.password = Devise.friendly_token[0, 10] if user.password.blank?
    user.name = auth.info.name                   unless auth.info.name.blank?
    user.nickname = auth.info.nickname           unless auth.info.nickname.blank? 
    user.first_name = auth.info.first_name       unless auth.info.first_name.blank?
    user.last_name = auth.info.last_name         unless auth.info.last_name.blank?
    user.location = auth.info.location           unless auth.info.location.blank?
    user.email = auth.info.email                 unless auth.info.email.blank?
    user.image = auth.info.image                 unless auth.info.image.blank?

    auth.provider == 'twitter' ? user.save(validate: false) : user.save

    authorization.nickname = auth.info.nickname
    authorization.user_id = user.id
    authorization.save

    authorization.user
  end

  def admin?
    (role == 'admin')
  end
end
