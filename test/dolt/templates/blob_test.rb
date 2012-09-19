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

class Blob
  attr_reader :content
  def initialize(content); @content = content; end
end

describe "blob template" do
  before do
    @repo = "the-dolt"
    @template_root = File.join(File.dirname(__FILE__), "..", "..", "..", "views")
  end

  def render(path, blob, options = {})
    options[:attributes] = options[:attributes] || {}
    attrs = options[:attributes]
    options.delete(:attributes)
    renderer = Dolt::TemplateRenderer.new(@template_root, options)
    if !attrs.key?(:multi_repo_mode); attrs[:multi_repo_mode] = true; end
    renderer.helper(Dolt::View.load_all(attrs))
    renderer.render(:blob, {
                      :blob => blob,
                      :repository => @repo,
                      :ref => options[:ref] || "master",
                      :path => path
                    })
  end

  it "renders blob without errors" do
    markup = render("file.txt", Blob.new("Something something"))

    assert_match /Something something/, markup
  end

  it "renders blob with line numbers" do
    markup = render("file.txt", Blob.new("One\nTwo\nThree"))

    assert_match /<li.*One.*<\/li>/, markup
    assert_match /<li.*Two.*<\/li>/, markup
    assert_match /<li.*Three.*<\/li>/, markup
  end

  it "renders blob with layout" do
    markup = render("file.txt", Blob.new("Something something"), :layout => "layout")

    assert_match /Something something/, markup
  end

  it "renders repo title in page" do
    @repo = "my-magic-repo"
    markup = render("file.txt", Blob.new("Something something"), :layout => "layout")

    assert_match "my-magic-repo", markup
  end

  it "renders links to other views" do
    markup = render("file.txt", Blob.new("Something something"))

    assert_match "/the-dolt/blame/master:file.txt", markup
    assert_match "/the-dolt/history/master:file.txt", markup
    assert_match "/the-dolt/raw/master:file.txt", markup
  end

  it "renders links to other views in single repo mode" do
    markup = render("file.txt", Blob.new("Something something"), { :attributes => { :multi_repo_mode => false } })

    assert_match "\"/blame/master:file.txt", markup
    assert_match "\"/history/master:file.txt", markup
    assert_match "\"/raw/master:file.txt", markup
  end

  it "renders links to other views for correct ref" do
    markup = render("file.txt", Blob.new("Something something"), :ref => "123bc21")

    assert_match "/the-dolt/blame/123bc21:file.txt", markup
    assert_match "/the-dolt/history/123bc21:file.txt", markup
    assert_match "/the-dolt/raw/123bc21:file.txt", markup
  end

  it "renders the path clickable" do
    markup = render("some/deeply/nested/file.txt", Blob.new("Something something"))

    assert_match 'href="/the-dolt/tree/master:some"', markup
    assert_match 'href="/the-dolt/tree/master:some/deeply"', markup
    assert_match 'href="/the-dolt/tree/master:some/deeply/nested"', markup
  end
end
