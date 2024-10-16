require "uuid"

module Authly
  struct Client
    getter name : String
    getter id : String
    getter secret : String
    getter redirect_uri : String
    getter scopes : String

    def initialize(@name, @secret, @redirect_uri, @id, @scopes = "read")
    end
  end

  class Clients
    include AuthorizableClient
    include Enumerable(Authly::Client)

    def initialize
      @clients = [] of Client
    end

    def <<(client : Client)
      @clients << client
    end

    def valid_redirect?(client_id, redirect_uri) : Bool
      any? do |client|
        client.id == client_id && client.redirect_uri == redirect_uri
      end
    end

    def authorized?(client_id, client_secret)
      any? do |client|
        client.id == client_id && client.secret == client_secret
      end
    end

    def authorized?(client_id, secret, redirect_uri, code, verifier : String? = nil)
      any? do |client|
        client.id == client_id && client.secret == secret && redirect_uri == redirect_uri
      end
    end

    def each(& : Client -> _)
      @clients.each { |client| yield client }
    end
  end
end
