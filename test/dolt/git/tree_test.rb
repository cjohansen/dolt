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
  describe "parse" do
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

      @tree = Dolt::Git::Tree.parse("./", lines)
    end

    it "has path" do
      assert_equal "./", @tree.path
    end

    it "extracts each line as an entry" do
      assert_equal 11, @tree.entries.length
    end

    it "extracts file entry objects" do
      gemfile = @tree.entries[1]

      assert gemfile.file?
      assert !gemfile.dir?
      assert_equal "Gemfile", gemfile.path
      assert_equal "100644", gemfile.mode
      assert_equal "c80ee3697054566d1a4247d80be78ec3ddfde295", gemfile.sha
    end

    it "extracts directory entry objects" do
      bin = @tree.entries[5]

      assert !bin.file?
      assert bin.dir?
      assert_equal "bin", bin.path
      assert_equal "040000", bin.mode
      assert_equal "18052467e73a1b7fb2613dc7b36baa554fab024b", bin.sha
    end
  end
end
