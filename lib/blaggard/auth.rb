require 'rack/auth/basic'
require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'

module Blaggard
  class Auth < Rack::Auth::Basic
    def call(env)
      @env = env
      @request = Rack::Request.new(env)
      @auth = Request.new(env)

      if not @auth.provided?
        unauthorized
      elsif not @auth.basic?
        bad_request
      else
        result = if (access = valid? and access == true)
                   @env['REMOTE_USER'] = @auth.username
                   @app.call(env)
                 else
                   if access == '404'
                     render_not_found
                   elsif access == '403'
                     render_no_access
                   else
                     unauthorized
                   end
                 end
        result
      end
    end# method call

    def valid?
      false
    end
  end# class Auth
end