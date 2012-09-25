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
require "ostruct"

class Repository
  attr_reader :name
  def initialize(name); @name = name; end
  def rev_parse(rev); stub; end
  def blame(ref, path); stub; end
  def log(ref, path, limit); stub; end
  def refs; stub; end

  def resolve_promise(blob)
    @deferred.resolve(blob)
  end

  private
  def stub
    @deferred = When::Deferred.new
    @deferred.promise
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
      @actions.blob("gitorious", "master", "app")

      assert_equal ["gitorious"], @resolver.resolved.map(&:name)
    end

    it "yields path, blob, repo, ref and base_tree_url to block" do
      data = nil
      @actions.blob("gitorious", "babd120", "app") do |err, d|
        data = d
      end

      @resolver.resolved.last.resolve_promise("Blob")

      assert_equal({
                     :blob => "Blob",
                     :repository => "gitorious",
                     :ref =>  "babd120",
                     :path => "app"
                   }, data)
    end
  end

  describe "#tree" do
    it "resolves repository" do
      @actions.tree("gitorious", "master", "app")

      assert_equal ["gitorious"], @resolver.resolved.map(&:name)
    end

    it "yields tree, repo and ref to block" do
      data = nil
      @actions.tree("gitorious", "babd120", "app") do |err, d|
        data = d
      end

      repo = @resolver.resolved.last
      repo.resolve_promise "Tree"

      expected = {
        :tree => "Tree",
        :repository => "gitorious",
        :ref =>  "babd120",
        :path => "app"
      }
      assert_equal expected, data
    end
  end

  describe "#blame" do
    it "resolves repository" do
      @actions.blame("gitorious", "master", "app")

      assert_equal ["gitorious"], @resolver.resolved.map(&:name)
    end

    it "yields blame, repo and ref to block" do
      data = nil
      @actions.blame("gitorious", "babd120", "app") do |err, d|
        data = d
      end

      repo = @resolver.resolved.last
      repo.resolve_promise "Blame"

      expected = {
        :blame => "Blame",
        :repository => "gitorious",
        :ref =>  "babd120",
        :path => "app"
      }
      assert_equal expected, data
    end
  end

  describe "#history" do
    it "resolves repository" do
      @actions.history("gitorious", "master", "app", 1)

      assert_equal ["gitorious"], @resolver.resolved.map(&:name)
    end

    it "yields commits, repo and ref to block" do
      data = nil
      @actions.history("gitorious", "babd120", "app", 2) do |err, d|
        data = d
      end

      repo = @resolver.resolved.last
      repo.resolve_promise "History"

      expected = {
        :commits => "History",
        :repository => "gitorious",
        :ref =>  "babd120",
        :path => "app"
      }
      assert_equal expected, data
    end
  end

  describe "#refs" do
    before do
      @refs = ["refs/stash",
               "refs/tags/v0.2.1",
               "refs/tags/v0.2.0",
               "refs/remotes/origin/master",
               "refs/heads/libgit2",
               "refs/heads/master"].map { |n| OpenStruct.new(:name => n) }
    end

    it "yields repositories, tags and heads" do
      data = nil
      @actions.refs("gitorious") { |err, d| data = d }

      repo = @resolver.resolved.last
      repo.resolve_promise(@refs)

      expected = {
        :repository => "gitorious",
        :heads => ["libgit2", "master"],
        :tags => ["v0.2.1", "v0.2.0"]
      }
      assert_equal expected, data
    end
  end
end
