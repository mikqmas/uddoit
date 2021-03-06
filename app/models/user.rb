class User < ApplicationRecord
  attr_reader :password

  has_many :user_todos, dependent: :destroy
  has_many :todos, through: :user_todos

  after_initialize :ensure_session_token
  validates :password_digest, presence: true
  validates :password, length: {minimum: 6, allow_nil: true}
  validates :session_token, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true


  def self.join_user_todo
    joins(:user_todos)
  end
  scope :user_join, -> { joins(:user_todos) }

  def reset_session_token!
    self.session_token = SecureRandom.urlsafe_base64(16)
    self.save!
    self.session_token
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def self.find_by_credentials(username, password)
    user = User.find_by(username: username)
    user.try(:is_password?, password) ? user : nil
  end

  def owned_todos
    self.user_todos.to_a.select do |el| el.is_owner end
  end

  private
  def ensure_session_token
    self.session_token ||= SecureRandom.urlsafe_base64(16)
  end

end
