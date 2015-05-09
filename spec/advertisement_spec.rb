require 'spec_helper'

describe Blaggard::Advertisement do
  subject{ Blaggard::Advertisement }
  context 'read' do
    before do
      @advert = subject.new(TestEnv.repo_path, ["group1", "group2"], 'upload-pack')
      @repo_branches = ["refs/heads/br2", "refs/heads/cannot-fetch",
                       "refs/heads/chomped", "refs/heads/haacked",
                       "refs/heads/master", "refs/heads/not-good",
                       "refs/heads/packed", "refs/heads/packed-test",
                       "refs/heads/subtrees", "refs/heads/test",
                       "refs/heads/track-local", "refs/heads/trailing"]
      @subset = ["refs/heads/test", "refs/heads/chomped"]
    end
    it 'should get the original advertisement properly' do
      raw = @advert.raw_refs
      expect(raw.first.split("\0").length).to eq(2)
      expect(raw.last).to eq("0000")
    end

    it 'should properly hash out ref names' do
      hash = @advert.refs_hash
      # We may add more tags and things to the repo, this makes sure the
      # basic subset is there for the test to pass
      expect(hash.keys & @repo_branches).to eq(@repo_branches)
    end

    it 'should get the accessible branches from the meta config when permission is *' do
      meta = @advert.instance_variable_get :@meta
      allow(meta).to receive(:branches).and_return(["refs/heads/*"])
      expect(@advert.accessible_branches).to eq(@repo_branches)
    end

    it 'should get a subset of branches for accessible branches' do
      meta = @advert.instance_variable_get :@meta
      allow(meta).to receive(:branches).and_return(@subset)
      expect(@advert.accessible_branches).to eq(@subset)
    end

    it 'should update_line_length properly' do
      wrong_line = "0042a65fedf39aefe402d3bb6e24df4d4f5fe4547750 HEAD\0multi_ack thin-pack side-band side-band-64k ofs-delta shallow no-progress include-tag multi_ack_detailed no-done symref=HEAD:refs/heads/master agent=git/2.0.1\n"
      right_line =  "00d1a65fedf39aefe402d3bb6e24df4d4f5fe4547750 HEAD\0multi_ack thin-pack side-band side-band-64k ofs-delta shallow no-progress include-tag multi_ack_detailed no-done symref=HEAD:refs/heads/master agent=git/2.0.1\n"
      expect(@advert.update_line_length(wrong_line)).to eq(right_line)
    end

    it 'should properly figure out if the user can access the current HEAD' do
      meta = @advert.instance_variable_get :@meta
      allow(meta).to receive(:can_access_branch?).with('group1', :read, "refs/heads/master").and_return(true)
      allow(meta).to receive(:can_access_branch?).with('group2', :read, "refs/heads/master").and_return(false)
      expect(@advert.can_access_head?).to eq(true)

      allow(meta).to receive(:can_access_branch?).with('group1', :read, "refs/heads/master").and_return(false)
      allow(meta).to receive(:can_access_branch?).with('group2', :read, "refs/heads/master").and_return(false)
      expect(@advert.can_access_head?).to eq(false)
    end

    context 'stubbed git call' do
      before do
        git = @advert.instance_variable_get :@git
        time_ordered_refs = ["refs/heads/subtrees", "refs/heads/master", "refs/heads/not-good", "refs/heads/test", "refs/heads/chomped", "refs/heads/trailing", "refs/heads/br2", "refs/heads/cannot-fetch", "refs/heads/track-local", "refs/heads/packed-test", "refs/heads/packed", "refs/heads/haacked"]
        allow(git).to receive(:time_ordered_refs).and_return(time_ordered_refs)
        allow(@advert).to receive(:accessible_branches).and_return(@subset)
      end
      it 'should update the HEAD line of the advertisement if user cannot access HEAD' do
        expect(@advert.update_head).to include("00cfe90810b8df3e80c413d903f631643c716887138d HEAD\0multi_ack thin-pack side-band side-band-64k ofs-delta shallow no-progress include-tag multi_ack_detailed no-done symref=HEAD:refs/heads/test")
      end
      it 'should output the correct full advertisement' do
        allow(@advert).to receive(:can_access_head?).and_return(true)
        git_version = `git --version`.split.last
        advertisement = "00d1a65fedf39aefe402d3bb6e24df4d4f5fe4547750 HEAD\0multi_ack thin-pack side-band side-band-64k ofs-delta shallow no-progress include-tag multi_ack_detailed no-done symref=HEAD:refs/heads/master agent=git/#{git_version}
003de90810b8df3e80c413d903f631643c716887138d refs/heads/test
0040e90810b8df3e80c413d903f631643c716887138d refs/heads/chomped
003fe90810b8df3e80c413d903f631643c716887138d refs/tags/test-r2
003f6dcf9bf7541ee10456529833502442f385010c3d refs/tags/test-r1
0000"
        expect(@advert.advertise).to eq(advertisement)
      end
    end
  end
end