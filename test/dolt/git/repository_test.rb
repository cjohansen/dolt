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
require "dolt/git/repository"

describe Dolt::Git::Repository do
  include EM::MiniTest::Spec

  describe "#blame" do
    before { @repository = Dolt::Git::Repository.new(".") }
    it "returns deferrable" do
      deferrable = @repository.blame("master", "Gemfile")
      assert deferrable.respond_to?(:callback)
      assert deferrable.respond_to?(:errback)
    end

    it "yields blame" do
      @repository.blame("master", "Gemfile").callback do |blame|
        assert Dolt::Git::Blame === blame
        done!
      end
      wait!
    end
  end
end
