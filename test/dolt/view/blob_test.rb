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
require "dolt/view/blob"

describe Dolt::View::Blob do
  include Dolt::View::Blob

  describe "single repo mode" do
    include Dolt::View::SingleRepository

    it "returns blame url" do
      url = blame_url("myrepo", "master", "some/path")
      assert_equal "/blame/master:some/path", url
    end

    it "returns history url" do
      url = history_url("myrepo", "master", "some/path")
      assert_equal "/history/master:some/path", url
    end

    it "returns raw url" do
      url = raw_url("myrepo", "master", "some/path")
      assert_equal "/raw/master:some/path", url
    end
  end

  describe "multi repo mode" do
    include Dolt::View::MultiRepository

    it "returns blame url" do
      url = blame_url("myrepo", "master", "some/path")
      assert_equal "/myrepo/blame/master:some/path", url
    end

    it "returns history url" do
      url = history_url("myrepo", "master", "some/path")
      assert_equal "/myrepo/history/master:some/path", url
    end

    it "returns raw url" do
      url = raw_url("myrepo", "master", "some/path")
      assert_equal "/myrepo/raw/master:some/path", url
    end
  end

  describe "#multiline" do
    it "adds line number markup to code" do
      html = multiline("A few\nLines\n    Here")

      assert_match "<pre", html
      assert_match "<ol class=\"linenums", html
      assert_match "<li class=\"L1\"><span class=\"line\">A few</span></li>", html
      assert_match "<li class=\"L2\"><span class=\"line\">Lines</span></li>", html
      assert_match "<li class=\"L3\"><span class=\"line\">    Here</span></li>", html
    end

    it "adds custom class name" do
      html = multiline("A few\nLines\n    Here", :class_names => ["ruby"])

      assert_match "prettyprint", html
      assert_match "linenums", html
      assert_match "ruby", html
    end
  end
end
