task :default => :test
 
desc "Run the tests."
task :test do
  system "bundle exec rspec spec"
end

task :console do
  system "./script/console"
end

namespace :blaggard do
  desc "Start Blaggard"
  task :start do
    system "./script/server"
  end
end
 
desc "Start everything."
multitask :start => [ 'blaggard:start' ]
