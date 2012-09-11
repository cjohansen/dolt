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

describe Dolt::Git::Blob do
  describe "#raw" do
    it "returns full raw blob" do
      blob = Dolt::Git::Blob.new("file.txt", "Something something")

      assert_equal "Something something", blob.raw
    end
  end

  describe "#lines" do
    it "returns empty array for empty blob" do
      blob = Dolt::Git::Blob.new("file.txt", "")

      assert_equal [], blob.lines
    end

    it "returns array of one line" do
      blob = Dolt::Git::Blob.new("file.txt", "Something something")

      assert_equal ["Something something"], blob.lines
    end

    it "returns array of lines" do
      blob = Dolt::Git::Blob.new("file.txt", "Something\nsomething\nYup")

      assert_equal ["Something", "something", "Yup"], blob.lines
    end
  end
end