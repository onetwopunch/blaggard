module Blaggard
  class Advertisement
    def initialize(repo_path, groups, service)
      @git = Blaggard::Git.new(repo_path)
      @meta = Blaggard::GroupConfig.new(repo_path)
      @groups = groups
      @repo_path = repo_path
      @service = service
      @priv = service == "upload-pack" ? :read : :write
      refs_hash
    end

    def raw_refs
      @raw_refs ||= @git.exec(%W(#{@service} --stateless-rpc --advertise-refs #{@repo_path})).split("\n")
      @first_ref_line ||= @raw_refs.first + "\n" # head_ref\0capabilities
      @pk_end ||= @raw_refs.last
      @raw_refs
    end

    def accessible_tags
      @tags || begin
        tags = accessible_branches.map{ |branch| @git.tags_on_branch(branch)}.flatten.compact
        tags.map{ |tag| "refs/tags/#{tag}"}.uniq
      rescue
        []
      end
    end

    def accessible_branches
      @branches || begin
        branches = @meta.branches(@groups, @priv)

        if branches.include? "refs/heads/*"
          return refs_hash.keys.select{ |ref| ref.start_with? "refs/heads/"}
        end
        branches
      end
    end

    def refs_hash
      # To access the refs quicker, put them in a hash where the ref name is the key
      @refs_hash ||= Hash[ raw_refs[1..-2].collect { |v| ary = v.split; [ary.last, ary.first] } ]
    end

    def update_head
      #sort refs by time since the most recent will be the HEAD if the user doesn't have access
      # to the actual head
      refs = @git.time_ordered_refs & accessible_branches
      new_head = refs.first
      line = @first_ref_line.gsub(/symref\=HEAD\:(.*?) /, "symref=HEAD:#{new_head} ")

      new_sha = refs_hash[new_head]
      line = line.gsub(/[a-f0-9]{44}/, new_sha)
      update_line_length(line)
    end

    def update_line_length(line)
      # Each line contains 4 bytes of line length followed by the ref followed by the branch name
      # When HEAD is not accessible we need to update the line length of the first ref which includes
      # all the capabilities

      # Len should be (line.length - 4) to account for the first 4 bytes, but Ruby parses the \0 as
      # unicode \u0000 which adds back 4 characters.
      len = line.encode('utf-8').length
      hex = "%04x" % len
      return "#{hex}#{line[4..-1]}"
    end


    def can_access_head?
      head_file = File.join(@repo_path, 'HEAD')
      ref = File.open(head_file, &:readline).split.last rescue (return false)
      @groups.each do |group|
        return true if @meta.can_access_branch?(group, @priv, ref)
      end
      return false
    end

    def advertise
      # Construct the new advertisement using the updated head and only the
      # branches accessible to the user
      # TODO: We need a quick way to get only the tags for the accessible branches.
      result = can_access_head? ? @first_ref_line : update_head
      result += accessible_branches.map{ |branch| "#{refs_hash[branch]} #{branch}" }.join("\n")
      result += "\n" unless accessible_tags.empty?
      result += accessible_tags.map{ |tag| "#{refs_hash[tag]} #{tag}" }.join("\n")
      result += "\n#{@pk_end}"

      return result
    end
  end
end