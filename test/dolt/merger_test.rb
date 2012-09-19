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
require "dolt/merger"
require "ostruct"

class Trouble
  def toil
    raise "Bubble bubble"
  end
end

describe Dolt::Merger do
  it "does nothing when merging no objects" do
    merged = Dolt::Merger.new([])

    assert_raises NoMethodError do
      merged.something
    end
  end

  it "proxies method call to only merged object" do
    merged = Dolt::Merger.new([OpenStruct.new({ :something => 42 })])

    assert_equal 42, merged.something
  end

  it "proxies method call with arguments" do
    array = []
    merged = Dolt::Merger.new([array])
    merged.push(42, 13)

    assert_equal [42, 13], array
  end

  it "proxies method call with block" do
    array = [1, 2, 3]
    merged = Dolt::Merger.new([array])

    assert_equal [7, 8, 9], merged.map { |n| n + 6 }
  end

  it "proxies to second object" do
    merged = Dolt::Merger.new([OpenStruct.new(), OpenStruct.new({ :b => 42 })])

    assert_equal 42, merged.b
  end

  it "stops after finding a match" do
    merged = Dolt::Merger.new([OpenStruct.new({ :toil => 42 }), Trouble.new])

    assert_equal 42, merged.toil
  end

  it "adds object" do
    merged = Dolt::Merger.new([OpenStruct.new({})])
    assert_raises(NoMethodError) { merged.toil }

    merged << OpenStruct.new({ :toil => 42 })
    assert_equal 42, merged.toil
  end

  it "respond_to? when implementation is available" do
    merged = Dolt::Merger.new([OpenStruct.new({ :boing => 42 })])

    assert merged.respond_to?(:boing)
  end
end
