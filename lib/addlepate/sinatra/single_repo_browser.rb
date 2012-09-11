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
require "addlepate/sinatra/base"

module Addlepate
  module Sinatra
    class SingleRepoBrowser < Addlepate::Sinatra::Base
      attr_reader :repo

      def initialize(repo, actions, renderer)
        @repo = repo
        super(actions, renderer)
      end

      aget "/" do
        redirect("/blob/master:Readme.md")
      end

      aget "/blob/*:*" do
        ref, path = params[:splat]
        blob(repo, ref, path)
      end

      aget "/blob/*" do
        redirect("/blob/master:" + params[:splat].join)
      end
    end
  end
end
