require 'spec_helper'

describe Blaggard::Git do
  subject { Blaggard::Git }
  before do
    @git = subject.new(TestEnv.repo_path)
  end
  it 'should correctly order the refs by time' do
    expected = ["refs/heads/subtrees", "refs/heads/master", "refs/heads/not-good",
                "refs/heads/test", "refs/heads/chomped", "refs/heads/trailing",
                "refs/heads/br2", "refs/heads/cannot-fetch", "refs/heads/track-local",
                "refs/heads/packed-test", "refs/heads/packed", "refs/heads/haacked"]
    expect(@git.time_ordered_refs).to eq(expected)
  end

  it 'should get only the tags for the selected branch' do
    expect(@git.tags_on_branch('refs/heads/test')).to eq(%W(test-r2 test-r1))
  end

  it 'should validate the git-ness of a directory' do
    expect(@git.is_valid_git_dir?).to eq(true)
  end
end