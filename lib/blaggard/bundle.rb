require 'rack/builder'
require 'blaggard/auth'
require 'blaggard/server'

module Blaggard
  module Bundle
    extend self

    def new(config)
      Rack::Builder.new do
        use Blaggard::Auth do |username, password|
          false
        end

        run Blaggard::Server.new(config)
      end
    end

  end
end