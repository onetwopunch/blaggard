require 'zlib'
require 'rack/request'
require 'rack/response'
require 'rack/utils'
require 'time'
require 'rack'
require 'yaml'

require 'blaggard/git'
require 'blaggard/server'
require 'blaggard/group_config'
require 'blaggard/advertisement'
require 'blaggard/auth'
require 'blaggard/bundle'
require 'blaggard/group_finder'


module Blaggard
  def self.app_root
    File.absolute_path(File.join(__FILE__, "../.."))
  end
  class App
    def initialize(config = nil)
      @server = Blaggard::Server.new(config)
    end
    def config
      @server.config
    end
    def call(env)
      @server.call env
    end
  end
end
