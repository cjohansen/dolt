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
require "dolt/view/multi_repository"
require "dolt/view/object"

describe Dolt::View::Object do
  include Dolt::View::Object

  describe "single repo mode" do
    include Dolt::View::SingleRepository

    it "returns blob url" do
      object = { :type => "blob", :name => "Gemfile" }
      url = object_url("myrepo", "master", "", object)
      assert_equal "/blob/master:Gemfile", url
    end

    it "returns tree url" do
      object = { :type => "tree", :name => "models" }
      url = object_url("myrepo", "master", "app", object)
      assert_equal "/tree/master:app/models", url
    end

    it "returns blob url in directory" do
      object = { :type => "blob", :name => "Gemfile" }
      url = object_url("myrepo", "master", "lib/mything", object)
      assert_equal "/blob/master:lib/mything/Gemfile", url
    end
  end

  describe "multi repo mode" do
    include Dolt::View::MultiRepository

    it "returns blob url" do
      object = { :type => "blob", :name => "Gemfile" }
      url = object_url("myrepo", "master", "", object)
      assert_equal "/myrepo/blob/master:Gemfile", url
    end

    it "returns blob url in directory" do
      object = { :type => "blob", :name => "Gemfile" }
      url = object_url("myrepo", "master", "lib/mything", object)
      assert_equal "/myrepo/blob/master:lib/mything/Gemfile", url
    end
  end

  describe "#object_icon_class" do
    it "returns blob icon type" do
      assert_equal "icon-file", object_icon_class({ :type => :blob })
    end

    it "returns tree icon type" do
      assert_equal "icon-folder-close", object_icon_class({ :type => :tree })
    end

    it "returns submodule icon type" do
      assert_equal "icon-hdd", object_icon_class({ :type => :submodule })
    end
  end

  it "links submodule object to submodule" do
    url = "git://gitorious.org/gitorious/ui3.git"
    object = { :type => :submodule, :url => url }
    assert_equal url, object_url("gitorious", "master", "vendor", object)
  end
end
