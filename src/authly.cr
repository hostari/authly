require "jwt"
require "json"
require "./authly/authorizable_owner"
require "./authly/authorizable_client"
require "./authly/**"

module Authly
  CONFIG = Configuration.new

  def self.configure(&)
    yield CONFIG
  end

  def self.config
    CONFIG
  end

  def self.clients
    CONFIG.clients
  end

  def self.owners
    CONFIG.owners
  end

  def self.code(response_type, *args)
    ResponseType.new(response_type, *args).decode
  end

  def self.access_token(grant_type, **args)
    Grant.new(grant_type, **args).token
  end

  def self.jwt_encode(payload)
    JWT.encode(payload, config.secret_key, config.algorithm)
  end

  def self.jwt_decode(token, secret_key = config.public_key)
    JWT.decode token, secret_key, config.algorithm
  end

  def self.introspect(token : String)
    # Decode the JWT, verify the signature and expiration
    payload, _header = jwt_decode(token)

    # Check if the token is expired (exp claim is typically in seconds since epoch)
    if Time.local.to_unix > payload["exp"].to_s.to_i
      return {active: false, exp: payload["exp"]}
    end

    # Return authly access token
    {
      active: true,
      scope:  payload["scope"],
      cid:    payload["cid"],
      exp:    payload["exp"],
      sub:    payload["sub"],
    }
  rescue JWT::DecodeError
    {active: false}
  end
end
