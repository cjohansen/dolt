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
require "mocha"
require "dolt/template_renderer"

module ViewHelper
  def say_it; "YES"; end
end

describe Dolt::TemplateRenderer do
  before { @root = "/dolt/views" }

  it "reads template from file" do
    File.expects(:read).with("/dolt/views/file.erb").returns("")
    renderer = Dolt::TemplateRenderer.new("/dolt/views")
    renderer.render(:file)
  end

  it "renders template with locals" do
    File.stubs(:read).returns("<%= name %>!")
    renderer = Dolt::TemplateRenderer.new(@root)

    assert_equal "Chris!", renderer.render(:file, { :name => "Chris"})
  end

  it "caches template in memory" do
    renderer = Dolt::TemplateRenderer.new(@root)
    File.stubs(:read).returns("Original")
    renderer.render(:file)
    File.stubs(:read).returns("Updated")

    assert_equal "Original", renderer.render(:file)
  end

  it "does not cache template in memory when configured not to" do
    renderer = Dolt::TemplateRenderer.new(@root, :cache => false)
    File.stubs(:read).returns("Original")
    renderer.render(:file)
    File.stubs(:read).returns("Updated")

    assert_equal "Updated", renderer.render(:file)
  end

  it "renders template with layout" do
    renderer = Dolt::TemplateRenderer.new("/", :layout => "layout")
    File.stubs(:read).with("/file.erb").returns("Template")
    File.stubs(:read).with("/layout.erb").returns("I give you: <%= yield %>")

    assert_equal "I give you: Template", renderer.render(:file)
  end

  it "renders template once without layout" do
    renderer = Dolt::TemplateRenderer.new("/", :layout => "layout")
    File.stubs(:read).with("/file.erb").returns("Template")
    File.stubs(:read).with("/layout.erb").returns("I give you: <%= yield %>")

    assert_equal "Template", renderer.render(:file, {}, :layout => nil)
  end

  it "renders template once with different layout" do
    renderer = Dolt::TemplateRenderer.new("/", :layout => "layout")
    File.stubs(:read).with("/file.erb").returns("Template")
    File.stubs(:read).with("/layout.erb").returns("I give you: <%= yield %>")
    File.stubs(:read).with("/layout2.erb").returns("I present you: <%= yield %>")

    html = renderer.render(:file, {}, :layout => "layout2")

    assert_equal "I present you: Template", html
  end

  it "renders templates of specific type" do
    renderer = Dolt::TemplateRenderer.new("/", :type => :str)
    File.stubs(:read).with("/file.str").returns("Hey!")

    assert_equal "Hey!", renderer.render(:file)
  end

  it "renders with helper object" do
    renderer = Dolt::TemplateRenderer.new("/")
    renderer.helper(ViewHelper)
    File.stubs(:read).with("/file.erb").returns("Say it: <%= say_it %>")

    assert_equal "Say it: YES", renderer.render(:file)
  end

  it "does not leak state across render calls" do
    renderer = Dolt::TemplateRenderer.new("/")
    File.stubs(:read).with("/file.erb").returns(<<-TEMPLATE)
<%= @response %><% @response = "NO" %><%= @response %>
    TEMPLATE

    assert_equal "NO", renderer.render(:file)
    assert_equal "NO", renderer.render(:file)
  end

  it "shares state between template and layout" do
    renderer = Dolt::TemplateRenderer.new("/", :layout => "layout")
    File.stubs(:read).with("/file.erb").returns(<<-TEMPLATE)
<% @response = "NO" %><h1><%= @response %></h1>
    TEMPLATE
    tpl = "<title><%= @response %></title><%= yield %>"
    File.stubs(:read).with("/layout.erb").returns(tpl)

    assert_equal "<title>NO</title><h1>NO</h1>\n", renderer.render(:file)
  end
end
