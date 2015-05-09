require 'spec_helper'

describe Blaggard::GroupConfig do
  subject { Blaggard::GroupConfig }
  before do
    @config = subject.new(TestEnv.repo_path)
  end

  it "should create the directory structure" do
    meta_dir = File.join(TestEnv.repo_path, 'refs/meta')
    expect(File.directory?(meta_dir)).to eq(true)
    expect(@config.groups).to eq({})
  end

  # This tests the cascade of group, priv and branch being created properly
  it "should add a branch to a group properly" do
    group = "admin_group"
    branch = "refs/heads/test"

    expect(@config.add_branch(group, :write, branch)).to eq(true)
    expect(@config.branches([group], :write)).to include(branch)
  end

  context 'delete' do
    before do
      @group = "admin_group"
      @branch = "refs/heads/test"
      @config.add_branch(@group, :write, @branch)
    end
    it 'should delete a branch properly' do

      expect(@config.delete_branch(@group, :write, @branch)).to eq(true)
      expect(@config.branches([@group], :write)).not_to include(@branch)
    end

    it 'should delete a group properly and validate group existence' do
      expect(@config.delete_group(@group)).to eq(true)
      begin
        @config.branches([@group], :write)
      rescue => e
        expect(e.message).to include("Group #{@group} does not exist.")
      end
    end
  end
  it 'should error if branch does not exist' do
    group = "admin_group"
    branch = "refs/heads/not-a-branch"
    begin
      @config.add_branch(group, :write, branch)
    rescue => e
      expect(e.message).to include("Branch name #{branch} invalid.")
    end
  end

  it 'should validate privilege type' do
    group = "admin_group"
    branch = "test"
    begin
      @config.add_branch(group, :invalid, branch)
    rescue => e
      expect(e.message).to eq("Privilege must be either :read or :write")
    end
  end
end