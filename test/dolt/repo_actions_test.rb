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
require "dolt/repo_actions"
require "dolt/async/when"

class Repository
  attr_reader :name
  def initialize(name); @name = name; end

  def blob(path, ref)
    @deferred = When::Deferred.new
    @deferred.promise
  end

  def tree(path, ref)
    @deferred = When::Deferred.new
    @deferred.promise
  end

  def resolve_promise(blob)
    @deferred.resolve(blob)
  end
end

class Resolver
  attr_reader :resolved
  def initialize; @resolved = []; end

  def resolve(repo)
    repository = Repository.new(repo)
    @resolved << repository
    repository
  end
end

describe Dolt::RepoActions do
  before do
    @resolver = Resolver.new
    @actions = Dolt::RepoActions.new(@resolver)
  end

  describe "#blob" do
    it "resolves repository" do
      @actions.blob("gitorious", "app", "master")

      assert_equal ["gitorious"], @resolver.resolved.map(&:name)
    end

    it "yields blob, repo, ref and base_tree_url to block" do
      data = nil
      @actions.blob("gitorious", "app", "babd120") do |status, d|
        data = d
      end

      repo = @resolver.resolved.last
      repo.resolve_promise "Blob"

      assert_equal({
        :blob => "Blob",
        :repository => repo,
        :ref =>  "babd120"
      }, data)
    end
  end

  describe "#tree" do
    it "resolves repository" do
      @actions.tree("gitorious", "app", "master")

      assert_equal ["gitorious"], @resolver.resolved.map(&:name)
    end

    it "yields tree, repo and ref to block" do
      data = nil
      @actions.tree("gitorious", "app", "babd120") do |status, d|
        data = d
      end

      repo = @resolver.resolved.last
      repo.resolve_promise "Tree"

      expected = { :tree => "Tree", :repository => repo, :ref =>  "babd120" }
      assert_equal expected, data
    end
 end
end
