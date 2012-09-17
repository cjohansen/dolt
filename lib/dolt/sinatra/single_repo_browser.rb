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
require "dolt/sinatra/base"

module Dolt
  module Sinatra
    class SingleRepoBrowser < Dolt::Sinatra::Base
      attr_reader :repo

      def initialize(repo, actions, renderer)
        @repo = repo
        super(actions, renderer)
      end

      def blob_url(repo, path, ref)
        "/blob/#{ref}:#{path}"
      end

      def tree_url(repo, path, ref)
        "/tree/#{ref}:#{path}"
      end

      aget "/" do
        redirect("/tree/master:")
      end

      aget "/tree/*:*" do
        tree(repo, params[:splat][1], params[:splat][0])
      end

      aget "/tree/*" do
        force_ref(params[:splat], "tree", "master")
      end

      aget "/blob/*:*" do
        ref, path = params[:splat]
        blob(repo, path, ref)
      end

      aget "/blob/*" do
        force_ref(params[:splat], "blob", "master")
      end

      private
      def force_ref(args, action, ref)
        redirect("/#{action}/#{ref}:" + args.join)
      end
    end
  end
end
