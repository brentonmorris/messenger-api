class User
  include Mongoid::Document
  include Mongoid::Timestamps

  devise :database_authenticatable, :validatable,
    :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  ## Database authenticatable
  field :email, type: String, default: ""
  field :encrypted_password, type: String, default: ""

  # JWT fields for devise-jwt
  field :jti, type: String, default: -> { SecureRandom.uuid }
  index({jti: 1}, {unique: true})

  has_many :messages, dependent: :destroy

  def self.primary_key
    "_id"
  end

  def self.find_for_jwt_authentication(sub)
    find(sub)
  end

  def jwt_payload
    {
      "id" => id.to_s,
      "email" => email,
      "iat" => Time.current.to_i
    }
  end

  def to_json_response
    {
      id: id.to_s,
      email: email
    }
  end

  # Add debugging for JWT authentication
  def self.jwt_revoked?(payload, user)
    JwtDenylist.jwt_revoked?(payload, user)
  end

  def revoke_jwt(payload)
    JwtDenylist.revoke_jwt(payload, self)
  end

  # Generate new JTI on logout to invalidate existing tokens
  def on_jwt_dispatch(token, payload)
  end
end
