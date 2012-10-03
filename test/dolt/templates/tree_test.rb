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
require "dolt/template_renderer"
require "dolt/view"

class Tree
  attr_reader :entries
  def initialize(entries); @entries = entries; end
end

describe "tree template" do
  include Dolt::ViewTest

  before do
    @repo = "the-dolt"
    @template_root = File.join(File.dirname(__FILE__), "..", "..", "..", "views")
  end

  def render(path, tree, options = {})
    renderer = prepare_renderer(@template_root, options)
    renderer.render(:tree, {
                      :tree => tree,
                      :repository => @repo,
                      :ref => options[:ref] || "master",
                      :path => path
                    })
  end

  it "renders empty tree" do
    tree = Tree.new([])
    markup = render("app/models", tree)

    assert_match /<table class="table table-striped gts-tree-explorer"/, markup
    assert_match /data-gts-tree-history="/, markup
  end
end
