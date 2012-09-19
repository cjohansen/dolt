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
require "dolt/view/object"

describe Dolt::View::Object do
  before { @view = Dolt::View::Object.new(:multi_repo_mode => false) }

  describe "single repo mode" do
    it "returns blob url" do
      object = { :type => "blob", :name => "Gemfile" }
      url = @view.object_url("myrepo", "master", "", object)
      assert_equal "/blob/master:Gemfile", url
    end

    it "returns tree url" do
      object = { :type => "tree", :name => "models" }
      url = @view.object_url("myrepo", "master", "app", object)
      assert_equal "/tree/master:app/models", url
    end

    it "returns blob url in directory" do
      object = { :type => "blob", :name => "Gemfile" }
      url = @view.object_url("myrepo", "master", "lib/mything", object)
      assert_equal "/blob/master:lib/mything/Gemfile", url
    end
  end

  describe "multi repo mode" do
    before { @view = Dolt::View::Object.new(:multi_repo_mode => true) }

    it "returns blob url" do
      object = { :type => "blob", :name => "Gemfile" }
      url = @view.object_url("myrepo", "master", "", object)
      assert_equal "/myrepo/blob/master:Gemfile", url
    end

    it "returns blob url in directory" do
      object = { :type => "blob", :name => "Gemfile" }
      url = @view.object_url("myrepo", "master", "lib/mything", object)
      assert_equal "/myrepo/blob/master:lib/mything/Gemfile", url
    end
  end

  it "returns blob icon type" do
    assert_equal "icon-file", @view.object_icon_class({ :type => :blob })
  end

  it "returns tree icon type" do
    assert_equal "icon-folder-close", @view.object_icon_class({ :type => :tree })
  end
end
