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
require "moron/template_renderer"

module ViewHelper
  def say_it; "YES"; end
end

describe Moron::TemplateRenderer do
  it "reads template from file" do
    File.expects(:read).with("/moron/views/file.erb").returns("")
    renderer = Moron::TemplateRenderer.new("/moron/views")
    renderer.render(:file)
  end

  it "renders template with locals" do
    File.stubs(:read).returns("<%= name %>!")
    renderer = Moron::TemplateRenderer.new("/moron/views")

    assert_equal "Chris!", renderer.render(:file, { :name => "Chris"})
  end

  it "caches template in memory" do
    renderer = Moron::TemplateRenderer.new("/moron/views")
    File.stubs(:read).returns("Original")
    renderer.render(:file)
    File.stubs(:read).returns("Updated")

    assert_equal "Original", renderer.render(:file)
  end

  it "does not cache template in memory when configured not to" do
    renderer = Moron::TemplateRenderer.new("/moron/views", :cache => false)
    File.stubs(:read).returns("Original")
    renderer.render(:file)
    File.stubs(:read).returns("Updated")

    assert_equal "Updated", renderer.render(:file)
  end

  it "renders template with layout" do
    renderer = Moron::TemplateRenderer.new("/", :layout => "layout")
    File.stubs(:read).with("/file.erb").returns("Template")
    File.stubs(:read).with("/layout.erb").returns("I give you: <%= yield %>")

    assert_equal "I give you: Template", renderer.render(:file)
  end

  it "renders str templates" do
    renderer = Moron::TemplateRenderer.new("/", :type => :str)
    File.stubs(:read).with("/file.str").returns("Hey!")

    assert_equal "Hey!", renderer.render(:file)
  end

  it "renders with helper module" do
    renderer = Moron::TemplateRenderer.new("/")
    renderer.helper(ViewHelper)
    File.stubs(:read).with("/file.erb").returns("Say it: <%= say_it %>")

    assert_equal "Say it: YES", renderer.render(:file)
  end
end
