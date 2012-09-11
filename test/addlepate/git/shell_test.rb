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
require "addlepate/git/shell"

describe Addlepate::Git::Shell do
  include EM::MiniTest::Spec
  include Addlepate::StdioStub

  it "assumes git dir in work tree" do
    expected_cmd = ["git --git-dir /somewhere/.git ",
                    "--work-tree /somewhere log"].join
    Addlepate::DeferrableChildProcess.expects(:open).with(expected_cmd)
    git = Addlepate::Git::Shell.new("/somewhere")
    git.git("log")
  end

  it "uses provided git dir" do
    expected_cmd = ["git --git-dir /somewhere/.git ",
                    "--work-tree /elsewhere log"].join
    Addlepate::DeferrableChildProcess.expects(:open).with(expected_cmd)
    git = Addlepate::Git::Shell.new("/elsewhere", "/somewhere/.git")
    git.git("log")
  end

  it "returns deferrable" do
    silence_stderr do
      git = Addlepate::Git::Shell.new("/somwhere")
      result = git.git("log")

      assert result.respond_to?(:callback)
      assert result.respond_to?(:errback)
    end
  end

  it "joins arguments with spaces" do
    expected_cmd = ["git --git-dir /somewhere/.git ",
                    "--work-tree /somewhere push origin master"].join
    Addlepate::DeferrableChildProcess.expects(:open).with(expected_cmd)
    git = Addlepate::Git::Shell.new("/somewhere")
    git.git("push", "origin", "master")
  end

  it "calls errback when git operation fails" do
    silence_stderr do
      git = Addlepate::Git::Shell.new("/somewhere")
      result = git.git("push", "origin", "master")
      result.errback do |status|
        refute status.nil?
        done!
      end
      wait!
    end
  end

  it "shows a file" do
    git = Addlepate::Git::Shell.new("/somewhere")
    git.expects(:git).with("show", "master:app/models/repository.rb")
    result = git.show("app/models/repository.rb", "master")
  end
end
