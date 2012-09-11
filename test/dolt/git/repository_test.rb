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
require "dolt/git/repository"
require "dolt/async/when"

class FakeGit
  attr_reader :cmds, :deferreds

  def initialize
    @cmds = []
    @deferreds = []
  end

  def show(path, ref)
    git("show", path, ref)
  end

  def ls_tree(path, ref)
    git("ls-tree", path, ref)
  end

  def git(*args)
    cmds << args
    deferred = When::Deferred.new
    deferreds << deferred.resolver
    deferred.promise
  end

  def last_command; cmds.last; end
  def last_resolver; deferreds.last; end
end

describe Dolt::Git::Repository do
  before { @git = FakeGit.new }

  describe "#blob" do
    it "uses git-show to cat file at ref" do
      repo = Dolt::Git::Repository.new("gitorious", @git)
      repo.blob("models/repository.rb", "master")

      assert_equal ["show", "models/repository.rb", "master"], @git.last_command
    end

    it "defaults to showing the file at HEAD" do
      repo = Dolt::Git::Repository.new("gitorious", @git)
      repo.blob("models/repository.rb")

      assert_equal ["show", "models/repository.rb", "HEAD"], @git.last_command
    end

    it "invokes callback with blob object" do
      repo = Dolt::Git::Repository.new("gitorious", @git)
      d = repo.blob("models/repository.rb")

      d.callback do |blob|
        assert_equal "class Repository;end", blob.raw
      end

      @git.last_resolver.resolve("class Repository;end")
    end
  end

  describe "#tree" do
    it "uses git ls-tree to list tree" do
      repo = Dolt::Git::Repository.new("gitorious", @git)
      repo.tree("app/models", "master")

      assert_equal ["ls-tree", "app/models", "master"], @git.last_command
    end

    it "defaults to listing tree at HEAD" do
      repo = Dolt::Git::Repository.new("gitorious", @git)
      repo.tree("app/models")

      assert_equal ["ls-tree", "app/models", "HEAD"], @git.last_command
    end

    it "invokes callback with tree object" do
      repo = Dolt::Git::Repository.new("gitorious", @git)
      d = repo.tree("app/models")

      d.callback do |tree|
        assert_equal 3, tree.entries.length
      end

      @git.last_resolver.resolve(<<-GIT)
100644 blob e90021f89616ddf86855d05337c188408d3b417e    .gitmodules
100644 blob c80ee3697054566d1a4247d80be78ec3ddfde295    Gemfile
100644 blob 0053b3c95b0d9faa4916f7cd5e559c2b0f138027    Gemfile.lock
      GIT
    end
  end
end
