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
require "addlepate/git/repository"
require "addlepate/async/when"

class FakeGit
  attr_reader :cmds, :deferreds

  def initialize
    @cmds = []
    @deferreds = []
  end

  def show(path, ref)
    cmds << ["show", path, ref]
    deferred = When::Deferred.new
    deferreds << deferred.resolver
    deferred.promise
  end

  def last_command; cmds.last; end
  def last_resolver; deferreds.last; end
end

describe Addlepate::Git::Repository do
  before { @git = FakeGit.new }

  describe "#blob" do
    it "uses git-show to cat file at ref" do
      repo = Addlepate::Git::Repository.new("gitorious", @git)
      repo.blob("models/repository.rb", "master")

      assert_equal ["show", "models/repository.rb", "master"], @git.last_command
    end

    it "defaults to showing the file at HEAD" do
      repo = Addlepate::Git::Repository.new("gitorious", @git)
      repo.blob("models/repository.rb")

      assert_equal ["show", "models/repository.rb", "HEAD"], @git.last_command
    end

    it "invokes callback with blob object" do
      repo = Addlepate::Git::Repository.new("gitorious", @git)
      d = repo.blob("models/repository.rb")

      d.callback do |blob|
        assert_equal "class Repository;end", blob.raw
      end

      @git.last_resolver.resolve("class Repository;end")
    end
  end
end
