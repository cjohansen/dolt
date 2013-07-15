# encoding: utf-8
#--
#   Copyright (C) 2013 Gitorious AS
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
require "rack/test"
require "pathname"
require "tiltout"
require "libdolt"
require "dolt/sinatra/multi_repo_browser"

ENV["RACK_ENV"] = "test"

describe Dolt::Sinatra::MultiRepoBrowser do
  include Rack::Test::Methods

  def app
    lookup = Test::Lookup.new(Stub::Blob.new)
    def lookup.repositories; []; end
    view = Tiltout.new(Dolt.template_dir)
    Dolt::Sinatra::MultiRepoBrowser.new(lookup, view)
  end

  it "serves the index" do
    get "/"
    assert_equal 200, last_response.status
  end

  it "redirects repo requests to main tree" do
    get "/gitorious.git"
    assert_equal 302, last_response.status
    assert_match "/gitorious.git/tree/HEAD:", last_response.headers["Location"]
  end
end
