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
require "dolt/git/blob"
require "dolt/git/repository"
require "dolt/template_renderer"
require "dolt/view"

describe "blob template" do
  before do
    @repo = Dolt::Git::Repository.new("the-dolt")
    @template_root = File.join(File.dirname(__FILE__), "..", "..", "..", "views")
  end

  def render(blob, options = {})
    options[:attributes] = options[:attributes] || {}
    attrs = options[:attributes]
    if !attrs.key?(:multi_repo_mode); attrs[:multi_repo_mode] = true; end
    renderer = Dolt::TemplateRenderer.new(@template_root, options)
    renderer.helper(Dolt::View)
    renderer.render(:blob, {
                      :blob => blob,
                      :repository => @repo,
                      :ref => options[:ref] || "master"
                    })
  end

  it "renders blob without errors" do
    blob = Dolt::Git::Blob.new("file.txt", "Something something")
    markup = render(blob)

    assert_match /Something something/, markup
  end

  it "renders blob with line numbers" do
    blob = Dolt::Git::Blob.new("file.txt", "One\nTwo\nThree")
    markup = render(blob)

    assert_match /<li.*One.*<\/li>/, markup
    assert_match /<li.*Two.*<\/li>/, markup
    assert_match /<li.*Three.*<\/li>/, markup
  end

  it "renders blob with layout" do
    blob = Dolt::Git::Blob.new("file.txt", "Something something")
    markup = render(blob, :layout => "layout")

    assert_match /Something something/, markup
  end

  it "renders repo title in page" do
    blob = Dolt::Git::Blob.new("file.txt", "Something something")
    markup = render(blob, :layout => "layout")

    assert_match @repo.name, markup
  end

  it "renders links to other views" do
    blob = Dolt::Git::Blob.new("file.txt", "Something something")
    markup = render(blob)

    assert_match "/the-dolt/blame/master:file.txt", markup
    assert_match "/the-dolt/history/master:file.txt", markup
    assert_match "/the-dolt/raw/master:file.txt", markup
  end

  it "renders links to other views in single repo mode" do
    blob = Dolt::Git::Blob.new("file.txt", "Something something")
    markup = render(blob, { :attributes => { :multi_repo_mode => false } })

    assert_match "\"/blame/master:file.txt", markup
    assert_match "\"/history/master:file.txt", markup
    assert_match "\"/raw/master:file.txt", markup
  end

  it "renders links to other views for correct ref" do
    blob = Dolt::Git::Blob.new("file.txt", "Something something")
    markup = render(blob, :ref => "123bc21")

    assert_match "/the-dolt/blame/123bc21:file.txt", markup
    assert_match "/the-dolt/history/123bc21:file.txt", markup
    assert_match "/the-dolt/raw/123bc21:file.txt", markup
  end

  it "renders the path clickable" do
    blob = Dolt::Git::Blob.new("some/deeply/nested/file.txt", "Something something")
    markup = render(blob)

    assert_match 'href="/the-dolt/tree/master:some"', markup
    assert_match 'href="/the-dolt/tree/master:some/deeply"', markup
    assert_match 'href="/the-dolt/tree/master:some/deeply/nested"', markup
  end
end
