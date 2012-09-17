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
require "ostruct"
require "eventmachine"
require "em_pessimistic"
require "dolt/git/shell"

describe Dolt::Git::Shell do
  include EM::MiniTest::Spec
  include Dolt::StdioStub

  def mock_child_process(method, deferred = EM::DefaultDeferrable.new)
    EMPessimistic::DeferrableChildProcess.expects(method).returns(deferred)
  end

  def mock_git(git, deferred = EM::DefaultDeferrable.new)
    git.expects(:git).returns(deferred)
  end

  describe "#git" do
    it "assumes git dir in work tree" do
      expected_cmd = ["git --git-dir /somewhere/.git ",
                      "--work-tree /somewhere log"].join
      mock_child_process(:open).with(expected_cmd)
      git = Dolt::Git::Shell.new("/somewhere")
      git.git("log")
    end

    it "uses provided git dir" do
      expected_cmd = ["git --git-dir /somewhere/.git ",
                      "--work-tree /elsewhere log"].join
      mock_child_process(:open).with(expected_cmd)
      git = Dolt::Git::Shell.new("/elsewhere", "/somewhere/.git")
      git.git("log")
    end

    it "returns deferrable" do
      git = Dolt::Git::Shell.new("/somwhere")
      result = git.git("log")

      assert result.respond_to?(:callback)
      assert result.respond_to?(:errback)
    end

    it "joins arguments with spaces" do
      expected_cmd = ["git --git-dir /somewhere/.git ",
                      "--work-tree /somewhere push origin master"].join
      mock_child_process(:open).with(expected_cmd)
      git = Dolt::Git::Shell.new("/somewhere")
      git.git("push", "origin", "master")
    end

    it "calls errback when git operation fails" do
      git = Dolt::Git::Shell.new("/somewhere")
      result = git.git("push", "origin", "master")
      result.errback do |data, status|
        assert_equal 128, status.exitstatus
        done!
      end
      wait!
    end
  end

  def simulate_git(stdout, stderr = nil, exit_code = nil)
    deferred = EM::DefaultDeferrable.new
    mock_git(@git, deferred)

    EM.next_tick do
      status = OpenStruct.new({ :exitstatus => exit_code || (stderr.nil? ? 0 : 1) })
      deferred.fail(stderr, status) if !stderr.nil?
      deferred.succeed(stdout, status) if !stdout.nil?
    end

    wait!
  end

  describe "#show" do
    before { @git = Dolt::Git::Shell.new("/somewhere") }

    it "shows a file" do
      mock_git(@git).with("show", "master:app/models/repository.rb")
      @git.show("app/models/repository.rb", "master")
    end

    it "yields Dolt::Git::WrongObjectTypeError when viewing tree as blob" do
      simulate_git(<<-GIT)
tree master:

.gitmodules
Gemfile
Gemfile.lock
Rakefile
Readme.md
bin/
dolt.gemspec
lib/
test/
vendor/
views/
      GIT

      @git.show("", "master").errback do |error|
        assert_equal 0, error.exit_code
        assert_match /not a blob object/, error.message
        assert Dolt::Git::WrongObjectTypeError === error
        done!
      end
    end
  end

  describe "#ls_tree" do
    before { @git = Dolt::Git::Shell.new("/somewhere") }

    it "lists tree root" do
      mock_git(@git).with("ls-tree", "master:./")

      result = @git.ls_tree("", "master")
    end

    it "lists tree root when starting with slash" do
      mock_git(@git).with("ls-tree", "master:./")

      result = @git.ls_tree("/", "master")
    end

    it "lists path with trailing slash" do
      mock_git(@git).with("ls-tree", "master:./app/models/")

      result = @git.ls_tree("app/models", "master")
    end

    it "lists path at given ref" do
      git = Dolt::Git::Shell.new("/somewhere")
      mock_git(git).with("ls-tree", "v2.0.0:./app/models/")

      result = git.ls_tree("app/models/", "v2.0.0")
    end

    it "yields Dolt::Git::NoRepositoryError" do
      simulate_git(nil, "fatal: Not a git repository (or any of the parent directories): .git", 128)

      @git.ls_tree("some-file", "HEAD").errback do |error|
        assert_equal 128, error.exit_code
        assert_match /Not a git repository/, error.message
        assert Dolt::Git::NoRepositoryError === error
        done!
      end
      wait!
    end

    it "yields Dolt::Git::WrongObjectTypeError" do
      simulate_git(nil, "fatal: not a tree object", 128)

      @git.ls_tree("some-file", "master").errback do |error|
        assert_equal 128, error.exit_code
        assert_match /not a tree object/, error.message
        assert Dolt::Git::WrongObjectTypeError === error
        done!
      end
    end

    it "yields Dolt::Git::InvalidObjectNameError" do
      simulate_git(nil, "fatal: Not a valid object name master:some/file.rb", 128)

      @git.ls_tree("some/file.rb", "master").errback do |error|
        assert_equal 128, error.exit_code
        assert_match /Not a valid object name/, error.message
        assert Dolt::Git::InvalidObjectNameError === error
        done!
      end
    end
  end
end
