#<div style='text-align:center'> Blaggard</div>
### <div style='text-align:center'> A Ruby/Rack Git Smart-HTTP Server Handler that implements a branch-level access control layer</div>
========================================

This project is a fork of [Grack](https://github.com/schacon/grack). Please refer to documentation and license on grack's README. The name came from the acronym **B**ranch **L**evel **A**ccess **C**ontrol for **G**it which obviously expands into Blaggard since everyone wants to be a pirate! Based on the [git protocol technical documentation](https://github.com/git/git/blob/master/Documentation/technical/http-protocol.txt), git servers have a state called 'Advertisement'. This is where the git server advertises what refs it has available. We can reliably hijack and reconstruct this advertisement to only allow certain users to view certain refs based on a configuration file.

I have made the configuration very open

## Blaggard is currently in BETA and accepting pull requests, feature requests, and issues

## Installation

To run as an executable:

    gem install blaggard
    cp $BLAGGARD_PATH/config.yml.example ~/config.yml

    # Edit ~/config.yml's project_root value to point to you repo's directory

    blaggard start ~/config.yml
    git clone localhost:8080/my_repo.git

To run as a mounted bundle in routes.rb of another Rack application:

```
mount Blaggard::Bundle.new({
  git_path:     /bin/git,
  project_root: path/to/repos,
  upload_pack:  true,
  receive_pack: true,
  use_acl: true,
  base_url: "https://my-name-server",
  group_resource: "blaggard_groups"
}), at: '/'
```

## Config

**Blaggard keeps all information about access control within the repo itself as an object.** To create a config file, use the command line interface:

    blaggard config path/to/repo path/to/config.yml

The config.yml is a list of group objects that correspond to the following format:

    group_name:
      # read and write must start with : to be parsed into symbols
      :read:
        # an array of branches that a group can read (clone, fetch, etc)
        - refs/heads/readable1
        - refs/heads/readable2
      :write:
        # an array of branches a group can write to (push, etc)
        - refs/heads/writeable1

    another_group:
      # even if a group has no privileges you must still include an
      # empty array
      :read: []
      # if a group has access to all branches (ie. admin)
      :write:
        - refs/heads/*

 The command line executable should let you know if your config file is both parsable and if there are any errors, what groups those errors belong to.


Once the config file is setup, the next step is to create an API that maps the group to a username. You do this by creating an api endpoint that Blaggard will call to fetch the group by the username provided in the http request variable `REMOTE_USER`. The endpoint should have the following format:

    "#{config[:base_url]}/#{config[:group_resource]}/:id"

as an example:

    "https://hostname.com/api/v1/blaggard_groups/jsmith"

This endpoint should return a JSON array of groups ( as strings ) that correspond to the groups specified in the Blaggard config like so:

    ["group_name"]

In this example, `jsmith` would now be able to read the branches `readable1` and `readable2` and be able to write to the branch `writeable1`


## Testing

 To run unit tests:

     rake test

 To run an interactive Pry console with all libraries loaded run:

     rake console

The test repository located at `spec/fixtures/spec_repo.git` is copied into a temp location before the tests and therefore the tests are dependent upon it staying the same. If you use this repo for testing in the console, just copy it to another directory and edit the startup config.yml to reflect that repo path.



## Contribution

1. Take a look at the Issues
2. Write a fix, making sure all tests run
3. Submit a Pull Request
4. Rejoice!
