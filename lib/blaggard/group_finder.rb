require 'net/http'
require 'json'
module Blaggard
  class GroupFinder
    def initialize(config)
      # Make your base url and resource something like:
      #
      #   https://example.com/api/v1/users_groups/user1
      #
      # Ideally this should bring down a list of strings that
      # will correspond to the group keys in the repo config.
      # These will be the groups that user is a part of. The
      # User is identified by their username over http auth
      # ie. the REMOTE_USER header.
      @url = "#{config[:base_url]}/#{config[:group_resource]}/:id"
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
