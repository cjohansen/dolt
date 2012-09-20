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
require "dolt/view/single_repository"
require "dolt/view/object"
require "dolt/view/tree"
require "ostruct"

describe Dolt::View::Tree do
  include Dolt::Html
  include Dolt::View::SingleRepository
  include Dolt::View::Object
  include Dolt::View::Tree

  describe "#tree_entries" do
    before do
      async = { :name => "async", :type => :tree }
      disk_repo_resolver = { :type => :blob, :name => "disk_repo_resolver.rb" }
      git = { :type => :tree, :name => "git" }
      repo_actions = { :type => :blob, :name => "repo_actions.rb" }
      sinatra = { :type => :tree, :name => "sinatra" }
      template_renderer = { :type => :blob, :name => "template_renderer.rb" }
      version = { :type => :blob, :name => "version.rb" }
      view_rb = { :type => :blob, :name => "view.rb" }
      view = { :type => :tree, :name => "view" }
      @tree = OpenStruct.new({ :entries => [async, disk_repo_resolver, git,
                                            repo_actions, sinatra, template_renderer,
                                            version, view_rb, view] })
    end

    it "groups tree by type, dirs first" do
      entries = tree_entries(@tree)

      assert_equal :tree, entries[0][:type]
      assert_equal :tree, entries[1][:type]
      assert_equal :tree, entries[2][:type]
      assert_equal :tree, entries[3][:type]
      assert_equal :blob, entries[4][:type]
      assert_equal :blob, entries[5][:type]
      assert_equal :blob, entries[6][:type]
      assert_equal :blob, entries[7][:type]
      assert_equal :blob, entries[8][:type]
    end

    it "sorts by name" do
      entries = tree_entries(@tree)

      assert_equal "async", entries[0][:name]
      assert_equal "git", entries[1][:name]
      assert_equal "sinatra", entries[2][:name]
      assert_equal "view", entries[3][:name]
      assert_equal "disk_repo_resolver.rb", entries[4][:name]
      assert_equal "repo_actions.rb", entries[5][:name]
      assert_equal "template_renderer.rb", entries[6][:name]
      assert_equal "version.rb", entries[7][:name]
      assert_equal "view.rb", entries[8][:name]
    end
  end

  describe "#tree_context" do
    def context(path)
      tree_context("gitorious", "master", path)
    end

    it "renders root as empty string" do
      assert_equal "", context("")
      assert_equal "", context("/")
      assert_equal "", context("./")
    end

    it "renders single path item as table row" do
      assert_equal 1, select(context("lib"), "tr").length
      assert_equal 1, select(context("./lib"), "tr").length
    end

    it "renders single path item in cell" do
      assert_equal 1, select(context("lib"), "td").length
    end

    it "renders single path item as link" do
      assert_equal 1, select(context("lib"), "a").length
      assert_match /lib/, select(context("lib"), "a").first
    end

    it "renders single path item with open folder icon" do
      assert_match /icon-folder-open/, select(context("lib"), "i").first
    end

    it "renders two path items as two table rows" do
      assert_equal 2, select(context("lib/dolt"), "tr").length
    end

    it "renders two path items with colspan in first row" do
      assert_match /colspan="6"/, select(context("lib/dolt"), "tr").first
      assert_match /colspan="5"/, select(context("lib/dolt"), "tr")[1]
      tr = select(context("lib/dolt"), "tr")[1]
      assert_equal 2, select(tr, "td").length
    end
  end
end
