module TestEnv
  extend self

  def setup
    puts "Copying spec/fixtures/spec_repo.git into spec/fixtures/tmp.git"
    FileUtils.cp_r "spec/fixtures/spec_repo.git", "spec/fixtures/tmp.git"
  end

  def repo_path
    File.absolute_path("spec/fixtures/tmp.git")
  end

  def clean
    puts "\nRemoving spec/fixtures/tmp.git"
    FileUtils.rm_rf "spec/fixtures/tmp.git"
  end
end