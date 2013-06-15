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
require "libdolt/view/single_repository"
require "libdolt/view/blob"
require "libdolt/view/tree"

module Dolt
  module Sinatra
    class SingleRepoBrowser < Dolt::Sinatra::Base
      include Dolt::View::SingleRepository
      include Dolt::View::Blob
      include Dolt::View::Tree
      attr_reader :repo

      def initialize(repo, actions, renderer)
        @repo = repo
        super(actions, renderer)
      end

      not_found { renderer.render("404") }

      get "/" do
        redirect("/tree/master:")
      end

      get "/tree/*:*" do
        ref, path = params[:splat]
        tree(repo, ref, path)
      end

      get "/tree/*" do
        force_ref(params[:splat], "tree", "master")
      end

      get "/blob/*:*" do
        ref, path = params[:splat]
        blob(repo, ref, path)
      end

      get "/blob/*" do
        force_ref(params[:splat], "blob", "master")
      end

      get "/raw/*:*" do
        ref, path = params[:splat]
        raw(repo, ref, path)
      end

      get "/raw/*" do
        force_ref(params[:splat], "raw", "master")
      end

      get "/blame/*:*" do
        ref, path = params[:splat]
        blame(repo, ref, path)
      end

      get "/blame/*" do
        force_ref(params[:splat], "blame", "master")
      end

      get "/history/*:*" do
        ref, path = params[:splat]
        history(repo, ref, path, (params[:commit_count] || 20).to_i)
      end

      get "/history/*" do
        force_ref(params[:splat], "blame", "master")
      end

      get "/refs" do
        refs(repo)
      end

      get "/tree_history/*:*" do
        ref, path = params[:splat]
        tree_history(repo, ref, path)
      end

      private
      def force_ref(args, action, ref)
        redirect("/#{action}/#{ref}:" + args.join)
      end
    end
  end
end
