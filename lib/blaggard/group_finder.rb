require 'net/http'
require 'json'
module Blaggard
  class GroupFinder
    def initialize(config)
      resource = 'api/v3/users_groups'
      @url = "#{config[:base_uri]}/#{resource}/:id?private_token=#{config[:auth_key]}"
    end

    def find(identifier)
      uri = URI(@url.gsub(':id', identifier))
      res = Net::HTTP.get_response(uri)
      if res.code == "200"
        return JSON.load(res.body)
      else
        []
      end
    end
  end
end
