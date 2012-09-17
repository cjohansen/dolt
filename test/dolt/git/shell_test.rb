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
require "eventmachine"
require "em_pessimistic"
require "dolt/git/shell"

describe Dolt::Git::Shell do
  include EM::MiniTest::Spec
  include Dolt::StdioStub

  describe "#git" do
    it "assumes git dir in work tree" do
      expected_cmd = ["git --git-dir /somewhere/.git ",
                      "--work-tree /somewhere log"].join
      EMPessimistic::DeferrableChildProcess.expects(:open).with(expected_cmd)
      git = Dolt::Git::Shell.new("/somewhere")
      git.git("log")
    end

    it "uses provided git dir" do
      expected_cmd = ["git --git-dir /somewhere/.git ",
                      "--work-tree /elsewhere log"].join
      EMPessimistic::DeferrableChildProcess.expects(:open).with(expected_cmd)
      git = Dolt::Git::Shell.new("/elsewhere", "/somewhere/.git")
      git.git("log")
    end

    it "returns deferrable" do
      silence_stderr do
        git = Dolt::Git::Shell.new("/somwhere")
        result = git.git("log")

        assert result.respond_to?(:callback)
        assert result.respond_to?(:errback)
      end
    end

    it "joins arguments with spaces" do
      expected_cmd = ["git --git-dir /somewhere/.git ",
                      "--work-tree /somewhere push origin master"].join
      EMPessimistic::DeferrableChildProcess.expects(:open).with(expected_cmd)
      git = Dolt::Git::Shell.new("/somewhere")
      git.git("push", "origin", "master")
    end

    it "calls errback when git operation fails" do
      silence_stderr do
        git = Dolt::Git::Shell.new("/somewhere")
        result = git.git("push", "origin", "master")
        result.errback do |data, status|
          refute status.nil?
          done!
        end
        wait!
      end
    end
  end

  describe "#show" do
    it "shows a file" do
      git = Dolt::Git::Shell.new("/somewhere")
      git.expects(:git).with("show", "master:app/models/repository.rb")
      result = git.show("app/models/repository.rb", "master")
    end
  end

  describe "#ls_tree" do
    it "lists tree root" do
      git = Dolt::Git::Shell.new("/somewhere")
      git.expects(:git).with("ls-tree", "master", "./")

      result = git.ls_tree("", "master")
    end

    it "lists tree root when starting with slash" do
      git = Dolt::Git::Shell.new("/somewhere")
      git.expects(:git).with("ls-tree", "master", "./")

      result = git.ls_tree("/", "master")
    end

    it "lists path with trailing slash" do
      git = Dolt::Git::Shell.new("/somewhere")
      git.expects(:git).with("ls-tree", "master", "./app/models/")

      result = git.ls_tree("app/models", "master")
    end

    it "lists path at given ref" do
      git = Dolt::Git::Shell.new("/somewhere")
      git.expects(:git).with("ls-tree", "v2.0.0", "./app/models/")

      result = git.ls_tree("app/models/", "v2.0.0")
    end
  end
end
