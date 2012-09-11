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
require "addlepate/git/blob"
require "addlepate/git/repository"
require "addlepate/template_renderer"
require "addlepate/view"

describe "blob template" do
  before do
    @repo = Addlepate::Git::Repository.new("the-addlepate")
    @template_root = File.join(File.dirname(__FILE__), "..", "..", "..", "views")
  end

  def render(blob, options = {})
    renderer = Addlepate::TemplateRenderer.new(@template_root, options)
    renderer.helper(Addlepate::View)
    renderer.render(:blob, {
                      :blob => blob,
                      :repository => @repo,
                      :ref => options[:ref] || "master"
                    })
  end

  it "renders blob without errors" do
    blob = Addlepate::Blob.new("file.txt", "Something something")
    markup = render(blob)

    assert_match /Something something/, markup
  end

  it "renders blob with line numbers" do
    blob = Addlepate::Blob.new("file.txt", "One\nTwo\nThree")
    markup = render(blob)

    assert_match /<li.*One.*<\/li>/, markup
    assert_match /<li.*Two.*<\/li>/, markup
    assert_match /<li.*Three.*<\/li>/, markup
  end

  it "renders blob with layout" do
    blob = Addlepate::Blob.new("file.txt", "Something something")
    markup = render(blob, :layout => "layout")

    assert_match /Something something/, markup
  end

  it "renders repo title in page" do
    blob = Addlepate::Blob.new("file.txt", "Something something")
    markup = render(blob, :layout => "layout")

    assert_match @repo.name, markup
  end

  it "renders links to other views" do
    blob = Addlepate::Blob.new("file.txt", "Something something")
    markup = render(blob)

    assert_match "/the-addlepate/blame/master:file.txt", markup
    assert_match "/the-addlepate/history/master:file.txt", markup
    assert_match "/the-addlepate/raw/master:file.txt", markup
  end

  it "renders links to other views for correct ref" do
    blob = Addlepate::Blob.new("file.txt", "Something something")
    markup = render(blob, :ref => "123bc21")

    assert_match "/the-addlepate/blame/123bc21:file.txt", markup
    assert_match "/the-addlepate/history/123bc21:file.txt", markup
    assert_match "/the-addlepate/raw/123bc21:file.txt", markup
  end

  it "renders the path clickable" do
    blob = Addlepate::Blob.new("some/deeply/nested/file.txt", "Something something")
    markup = render(blob)

    assert_match 'href="/the-addlepate/tree/master:some"', markup
    assert_match 'href="/the-addlepate/tree/master:some/deeply"', markup
    assert_match 'href="/the-addlepate/tree/master:some/deeply/nested"', markup
  end
end
