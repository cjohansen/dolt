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
require "sinatra"
require "sinatra/async"
require "eventmachine"

module Moron
  class SinatraServer < Sinatra::Base
    register Sinatra::Async

    def initialize(server, renderer)
      @server = server
      @renderer = renderer
      super()
    end

    def error(status)
      response["Content-Type"] = "text/plain"
      body("Process failed with exit code \n#{status.exitstatus}")
    end

    aget "/*/blob/*:*" do
      repo, ref, path = params[:splat]
      tree = server.blob(repo, ref, path) do |status, data|
        if status.nil?
          response["Content-Type"] = "text/html"
          body(renderer.render(:blob, data))
        else
          error(status)
        end
      end
    end

    private
    def renderer; @renderer; end
    def server; @server; end
  end
end
