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
require "moron/git/blob"
require "moron/git/repository"
require "moron/template_renderer"
require "moron/view"

describe "blob template" do
  before do
    @repo = Moron::Git::Repository.new("the-moron")
    @template_root = File.join(File.dirname(__FILE__), "..", "..", "..", "views")
  end

  def render(blob, options = {})
    renderer = Moron::TemplateRenderer.new(@template_root, options)
    renderer.helper(Moron::View)
    renderer.render(:blob, {
                      :blob => blob,
                      :repository => @repo,
                      :ref => options[:ref] || "master"
                    })
  end

  it "renders blob without errors" do
    blob = Moron::Blob.new("file.txt", "Something something")
    markup = render(blob)

    assert_match /Something something/, markup
  end

  it "renders blob with line numbers" do
    blob = Moron::Blob.new("file.txt", "One\nTwo\nThree")
    markup = render(blob)

    assert_match /<li.*One.*<\/li>/, markup
    assert_match /<li.*Two.*<\/li>/, markup
    assert_match /<li.*Three.*<\/li>/, markup
  end

  it "renders blob with layout" do
    blob = Moron::Blob.new("file.txt", "Something something")
    markup = render(blob, :layout => "layout")

    assert_match /Something something/, markup
  end

  it "renders repo title in page" do
    blob = Moron::Blob.new("file.txt", "Something something")
    markup = render(blob, :layout => "layout")

    assert_match @repo.name, markup
  end

  it "renders links to other views" do
    blob = Moron::Blob.new("file.txt", "Something something")
    markup = render(blob)

    assert_match "/the-moron/blame/master:file.txt", markup
    assert_match "/the-moron/history/master:file.txt", markup
    assert_match "/the-moron/raw/master:file.txt", markup
  end

  it "renders links to other views for correct ref" do
    blob = Moron::Blob.new("file.txt", "Something something")
    markup = render(blob, :ref => "123bc21")

    assert_match "/the-moron/blame/123bc21:file.txt", markup
    assert_match "/the-moron/history/123bc21:file.txt", markup
    assert_match "/the-moron/raw/123bc21:file.txt", markup
  end

  it "renders the path clickable" do
    blob = Moron::Blob.new("some/deeply/nested/file.txt", "Something something")
    markup = render(blob)

    assert_match 'href="/the-moron/tree/master:some"', markup
    assert_match 'href="/the-moron/tree/master:some/deeply"', markup
    assert_match 'href="/the-moron/tree/master:some/deeply/nested"', markup
  end
end
