module Blaggard
  class GroupConfigError < StandardError; end
  class GroupConfig
    # groups is an object like this:
    # {
    #     # group: { 'read': [refs]
    #     #          'write': [refs]}
    #     "admin_users" => {
    #         'read' => ['refs/heads/*'],
    #         'write' => ['refs/heads/haacked', 'refs/heads/master']
    #     },
    #     "normal_users" => {
    #         'read' => ['refs/heads/*'],
    #         'write' => []
    #     }
    # }
    attr_accessor :groups, :git
    def initialize( repo_path )
      @repo_path = repo_path
      @git = Blaggard::Git.new(repo_path)
      @config_path = File.join(@repo_path, 'refs/meta')
      unless File.directory?(@config_path)
        FileUtils.mkdir_p(File.join(@repo_path, 'refs/meta'))
      end
      @config_file = File.join(@config_path, 'config')
      read_from_git
    end

    def write_to_git
      tmp_file = File.absolute_path File.join(@config_path, 'tmp')
      if File.exist? tmp_file
        # tmp acts like a lock file to prevent multiple writes at the same time.
        raise Blaggard::GroupConfigError, "Unable to write to meta config, someone else is currently using it. Try again in a few minutes."
      end
      File.open( tmp_file , 'w' ) do |f|
        f.write(YAML.dump @groups)
      end

      ref = git.execute(['hash-object', '-w', tmp_file])
      File.open( @config_file , 'w') do |f|
        f.write(ref)
      end
      FileUtils.rm(tmp_file)
      return true
    end

    def read_from_git
      ref = File.open(@config_file, &:readline).chomp
      yml = git.execute(['cat-file', '-p', ref])
      @groups = YAML.load yml
      return @groups
    rescue
      @groups = {}
    end

    def add_branch(group, priv, branch)
      @groups = read_from_git
      @groups[group] = {:read =>[], :write => []} unless @groups[group]
      validate_privilege priv
      unless @groups[group][priv].include? branch
        if valid_branch_name? branch
          @groups[group][priv] << branch
          write_to_git
        else
          raise Blaggard::GroupConfigError, "Branch name #{branch} invalid. Must be of format 'refs/heads/<branch_name>"
        end
      end
    end

    def delete_branch(group, priv, branch)
      @groups = read_from_git
      validate_group group
      validate_privilege priv
      if @groups[group][priv].delete(branch)
        write_to_git
      else
        return false
      end
    end

    def delete_group(group)
      @groups = read_from_git
      validate_group group
      if @groups.delete(group)
        write_to_git
      else
        false
      end
    end

    def can_access_branch?(group, priv, branch)
      validate_group group rescue (return false)
      validate_privilege priv
      @groups[group][priv].include? branch
    end

    def branches(user_groups, priv)
      validate_privilege priv
      user_groups.map{ |group|
        validate_group group rescue next
        @groups[group][priv]
      }.uniq.flatten.compact
    end

    def valid_branch_name?(branch)
      valid_branches = Dir[File.join(@repo_path, 'refs/heads/*')].map{|b| b.split('/')[-3..-1].join('/')}
      valid_branches << 'refs/heads/*'
      return valid_branches.include?(branch)
    end

    # Validation Methods

    def validate_group(group)
      unless @groups[group]
        raise Blaggard::GroupConfigError, "Group #{group} does not exist. Use add_branch to create it."
      end
    end

    def validate_privilege(priv)
      raise Blaggard::GroupConfigError, "Privilege must be either :read or :write" unless [:read, :write].include?(priv)
    end
  end
end
