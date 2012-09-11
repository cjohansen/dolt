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
require "moron/sinatra/base"

module Moron
  module Sinatra
    class MultiRepoBrowser < Moron::Sinatra::Base
      aget "/" do
        response["Content-Type"] = "text/html"
        body("<h1>Welcome to Moron</h1>")
      end

      aget "/*/blob/*:*" do
        blob(*params[:splat])
      end

      aget "/*/blob/*" do
        redirect(params[:splat].shift + "/blob/master:" + params[:splat].join)
      end
    end
  end
end