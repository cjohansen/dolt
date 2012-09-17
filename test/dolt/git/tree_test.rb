# encoding: utf-8
#--
#   Copyright (C) 2012 Gitorious AS
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
require "test_helper"
require "dolt/git/tree"

describe Dolt::Git::Tree do
  describe "parsing root tree" do
    before do
      lines = <<-GIT
100644 blob e90021f89616ddf86855d05337c188408d3b417e    .gitmodules
100644 blob c80ee3697054566d1a4247d80be78ec3ddfde295    Gemfile
100644 blob 0053b3c95b0d9faa4916f7cd5e559c2b0f138027    Gemfile.lock
100644 blob 2ad22ff4b188c256d8ac97ded87c1c6ef6e96e43    Rakefile
100644 blob c8d1d197abfcd0f96c47583ec5f4328565cba433    Readme.md
040000 tree 18052467e73a1b7fb2613dc7b36baa554fab024b    bin
100644 blob e83bb675977e7277698320cdd9c595c5698e5aa5    dolt.gemspec
040000 tree 4b051dd46c3ba70fbfd6a2484ec00121a70bee3a    lib
040000 tree 86b096dc99b2cba28daa7676ed0dd38f709527b2    test
040000 tree d74d6bcb50cc5de9eb8fe019d7798b04d3a427e9    vendor
040000 tree be8fb09b735ac23265db2bec7c23e022a99ee730    views
      GIT

      @tree = Dolt::Git::Tree.parse("", lines)
    end

    it "has path" do
      assert_equal "./", @tree.path
    end

    it "extracts each line as an entry" do
      assert_equal 11, @tree.entries.length
    end

    it "extracts file entry objects" do
      gemfile = @tree.entries[6]

      assert gemfile.file?
      assert !gemfile.dir?
      assert_equal "Gemfile", gemfile.path
      assert_equal "Gemfile", gemfile.full_path
      assert_equal "100644", gemfile.mode
      assert_equal "c80ee3697054566d1a4247d80be78ec3ddfde295", gemfile.sha
    end

    it "extracts directory entry objects" do
      bin = @tree.entries[0]

      assert !bin.file?
      assert bin.dir?
      assert_equal "bin", bin.path
      assert_equal "040000", bin.mode
      assert_equal "18052467e73a1b7fb2613dc7b36baa554fab024b", bin.sha
    end
  end

  describe "parsing nested tree" do
    before do
      lines = <<-GIT
040000 tree c1d92125977841b672a10c96c6800e1b360a4e62    lib/dolt/async
100644 blob 6da3991090ba2df53eabe05bf4330aadf370a43a    lib/dolt/disk_repo_resolver.rb
040000 tree 0142bdb42936094cdd92aa188d3193be85f7a6c1    lib/dolt/git
100644 blob 2b8674702e62aaa5607317ed83085e74a62b9781    lib/dolt/repo_actions.rb
040000 tree d93b4afc62ad460387cf5d91d98d1ad306219419    lib/dolt/sinatra
100644 blob 2a7e89f4b940e23a3d921199d9000e93da299872    lib/dolt/template_renderer.rb
100644 blob dfe78a965009e27d9cce7c9733787acb564b6630    lib/dolt/version.rb
100644 blob 685369dd2a66f0313b232ee898f8bbdafec6862d    lib/dolt/view.rb
040000 tree 78347f337aaa613eb0a1c27ae7f89e39a22dcd6f    lib/dolt/view
      GIT

      @tree = Dolt::Git::Tree.parse("lib/dolt", lines)
    end

    it "does not include ./ in path" do
      assert_equal "lib/dolt", @tree.path
    end

    it "strips root path from entries" do
      assert_equal "disk_repo_resolver.rb", @tree.entries[4].path
    end

    it "groups tree by type, dirs first" do
      assert @tree.entries[0].dir?
      assert @tree.entries[1].dir?
      assert @tree.entries[2].dir?
      assert @tree.entries[3].dir?
      assert @tree.entries[4].file?
      assert @tree.entries[5].file?
      assert @tree.entries[6].file?
      assert @tree.entries[7].file?
      assert @tree.entries[8].file?
    end

    it "sorts tree entries alphabetically" do
      assert_equal "async", @tree.entries[0].path
      assert_equal "git", @tree.entries[1].path
      assert_equal "sinatra", @tree.entries[2].path
      assert_equal "view", @tree.entries[3].path
      assert_equal "disk_repo_resolver.rb", @tree.entries[4].path
      assert_equal "repo_actions.rb", @tree.entries[5].path
      assert_equal "template_renderer.rb", @tree.entries[6].path
      assert_equal "version.rb", @tree.entries[7].path
      assert_equal "view.rb", @tree.entries[8].path
    end
  end

  describe "parsing nested tree displayed relatively" do
    before do
      lines = <<-GIT
040000 tree c1d92125977841b672a10c96c6800e1b360a4e62    async
100644 blob 6da3991090ba2df53eabe05bf4330aadf370a43a    disk_repo_resolver.rb
040000 tree 0142bdb42936094cdd92aa188d3193be85f7a6c1    git
100644 blob 2b8674702e62aaa5607317ed83085e74a62b9781    repo_actions.rb
040000 tree d93b4afc62ad460387cf5d91d98d1ad306219419    sinatra
100644 blob 2a7e89f4b940e23a3d921199d9000e93da299872    template_renderer.rb
100644 blob dfe78a965009e27d9cce7c9733787acb564b6630    version.rb
100644 blob 685369dd2a66f0313b232ee898f8bbdafec6862d    view.rb
040000 tree 78347f337aaa613eb0a1c27ae7f89e39a22dcd6f    view
      GIT

      @tree = Dolt::Git::Tree.parse("./lib/dolt", lines)
    end

    it "does not include ./ in path" do
      assert_equal "lib/dolt", @tree.path
    end

    it "strips root path from entries" do
      assert_equal "disk_repo_resolver.rb", @tree.entries[4].path
    end

    it "groups tree by type, dirs first" do
      assert @tree.entries[0].dir?
      assert @tree.entries[1].dir?
      assert @tree.entries[2].dir?
      assert @tree.entries[3].dir?
      assert @tree.entries[4].file?
      assert @tree.entries[5].file?
      assert @tree.entries[6].file?
      assert @tree.entries[7].file?
      assert @tree.entries[8].file?
    end

    it "sorts tree entries alphabetically" do
      assert_equal "lib/dolt/async", @tree.entries[0].full_path
      assert_equal "lib/dolt/git", @tree.entries[1].full_path
      assert_equal "lib/dolt/sinatra", @tree.entries[2].full_path
      assert_equal "lib/dolt/view", @tree.entries[3].full_path
      assert_equal "lib/dolt/disk_repo_resolver.rb", @tree.entries[4].full_path
      assert_equal "lib/dolt/repo_actions.rb", @tree.entries[5].full_path
      assert_equal "lib/dolt/template_renderer.rb", @tree.entries[6].full_path
      assert_equal "lib/dolt/version.rb", @tree.entries[7].full_path
      assert_equal "lib/dolt/view.rb", @tree.entries[8].full_path
    end
  end
end
