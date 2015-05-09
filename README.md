#<div style='text-align:center'> Blaggard</div>
### <div style='text-align:center'> A Ruby/Rack Git Smart-HTTP Server Handler that implements a branch-level access control layer</div>
========================================

This project is a fork of [Grack](https://github.com/schacon/grack). Please refer to documentation and license on grack's README. The name came from the acronym **B**ranch **L**evel **A**ccess **C**ontrol for **G**it which obviously expands into Blaggard since everyone wants to be a pirate...arrrr!

## Installation

To run as an executable:

    gem install blaggard
    cp $BLAGGARD_PATH/config.yml.example ~/config.yml
    
    # Edit ~/config.yml's project_root value to point to you repo's directory
    
    blaggard start ~/config.yml
    git clone localhost:8080/my_repo.git
    
To run as a mounted bundle in routes.rb of another Rack application: 
  
    mount Blaggard::Bundle.new({
	    git_path:     /bin/git,
	    project_root: path/to/repos,
	    upload_pack:  true,
	    receive_pack: true,
	    use_acl: true
	  }), at: '/'
    
## Config

Blaggard keeps all information about access control within the repo itself as an object. To create a config file, use the command line interface:

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
 







