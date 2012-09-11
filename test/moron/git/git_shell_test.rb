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
require "moron/git/git_shell"

describe Moron::GitShell do
  include EM::MiniTest::Spec
  include Moron::StdioStub

  it "assumes git dir in work tree" do
    expected_cmd = ["git --git-dir /somewhere/.git ",
                    "--work-tree /somewhere log"].join
    Moron::DeferrableChildProcess.expects(:open).with(expected_cmd)
    git = Moron::GitShell.new("/somewhere")
    git.git("log")
  end

  it "uses provided git dir" do
    expected_cmd = ["git --git-dir /somewhere/.git ",
                    "--work-tree /elsewhere log"].join
    Moron::DeferrableChildProcess.expects(:open).with(expected_cmd)
    git = Moron::GitShell.new("/elsewhere", "/somewhere/.git")
    git.git("log")
  end

  it "returns deferrable" do
    silence_stderr do
      git = Moron::GitShell.new("/somwhere")
      result = git.git("log")

      assert result.respond_to?(:callback)
      assert result.respond_to?(:errback)
    end
  end

  it "joins arguments with spaces" do
    expected_cmd = ["git --git-dir /somewhere/.git ",
                    "--work-tree /somewhere push origin master"].join
    Moron::DeferrableChildProcess.expects(:open).with(expected_cmd)
    git = Moron::GitShell.new("/somewhere")
    git.git("push", "origin", "master")
  end

  it "calls errback when git operation fails" do
    silence_stderr do
      git = Moron::GitShell.new("/somewhere")
      result = git.git("push", "origin", "master")
      result.errback do |status|
        refute status.nil?
        done!
      end
      wait!
    end
  end
end
