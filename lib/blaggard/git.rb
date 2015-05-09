module Blaggard

  class Git
    attr_accessor :git_path, :repo

    def initialize(repo, path = nil)
      @repo = repo
      @git_path = path ? path : 'git'
    end

    def execute(cmd)
      cmd = command(cmd)
      if block_given?
        IO.popen(popen_env, cmd, File::RDWR, popen_options) do |pipe|
          yield(pipe)
        end
      else
        capture(cmd).chomp
      end
    end

    def time_ordered_refs
      opts = %W(--sort=-committerdate refs/heads/ --format=%(refname))
      return execute(['for-each-ref', opts]).split("\n")
    end

    def tags_on_branch(commitish)
      opts = %W(--simplify-by-decoration --decorate --pretty=oneline)
      return execute(['log', opts, commitish]).scan(/tag: (.*?)(\,|\))/).map{ |match| match.first}
    rescue => e
      []
    end

    def command(cmd)
      [git_path || 'git'] + cmd.flatten
    end

    def capture(command)
      IO.popen(popen_env, command, popen_options).read
    end

    def popen_options
      {chdir: repo, unsetenv_others: true}
    end

    def popen_env
      {'PATH' => ENV['PATH'], 'GL_ID' => ENV['GL_ID']}
    end

    def get_config_setting(service_name)
      service_name = service_name.gsub('-', '')
      setting = get_git_config("http.#{service_name}")
      if service_name == 'uploadpack'
        return setting != 'false'
      else
        return setting == 'true'
      end
    end

    def get_git_config(config_name)
      execute(%W(config #{config_name}))
    end

    def valid_repo?
      return false unless File.exists?(repo) &&
        File.realpath(repo) == repo
      match = execute(%W(rev-parse --git-dir)).match(/\.$|\.git$/)

      if match.to_s == '.git'
        # Since the parent could be a git repo, we want to make sure the actual repo contains a git dir.
        return false unless Dir.entries(repo).include?('.git')
      end

      !!match
    end

    def update_server_info
      # TODO: Update this for use with ACL
      execute(%W(update-server-info))
    end
  end
end
