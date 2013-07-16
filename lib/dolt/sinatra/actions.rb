# encoding: utf-8
#--
#   Copyright (C) 2012-2013 Gitorious AS
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
require "json"
require "time"
require "cgi"
require "libdolt/controller_actions"

module Dolt
  module Sinatra
    class Actions
      def initialize(app, lookup, renderer)
        @app = app
        @dolt = Dolt::ControllerActions.new(app, lookup, renderer)
      end

      def respond_to?(method)
        dolt.respond_to?(method)
      end

      def method_missing(method, *args, &block)
        if dolt.respond_to?(method)
          return respond(dolt.send(method, *args, &block))
        end
        super
      end

      private
      attr_reader :app, :dolt

      def respond(response)
        app.response.status = response[0]
        response[1].keys.each do |header|
          app.response[header] = response[1][header]
        end
        app.body(response[2].join("\n"))
      end
    end
  end
end
