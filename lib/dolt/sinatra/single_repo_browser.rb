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
require "sinatra/base"
require "dolt/sinatra/actions"
require "libdolt/view/single_repository"
require "libdolt/view/blob"
require "libdolt/view/tree"

module Dolt
  module Sinatra
    class SingleRepoBrowser < ::Sinatra::Base
      include Dolt::View::SingleRepository
      include Dolt::View::Blob
      include Dolt::View::Tree

      def initialize(repo, lookup, renderer)
        @repo = repo
        @lookup = lookup
        @renderer = renderer
        super()
      end

      not_found { renderer.render("404") }

      get "/" do
        redirect("/tree/HEAD:")
      end

      get "/tree/*:*" do
        begin
          ref, path = params[:splat]
          dolt.tree(repo, ref, path)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      get "/tree/*" do
        dolt.force_ref(params[:splat], "tree", "HEAD")
      end

      get "/blob/*:*" do
        begin
          ref, path = params[:splat]
          dolt.blob(repo, ref, path)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      get "/blob/*" do
        dolt.force_ref(params[:splat], "blob", "HEAD")
      end

      get "/raw/*:*" do
        begin
          ref, path = params[:splat]
          dolt.raw(repo, ref, path)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      get "/raw/*" do
        dolt.force_ref(params[:splat], "raw", "HEAD")
      end

      get "/blame/*:*" do
        begin
          ref, path = params[:splat]
          dolt.blame(repo, ref, path)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      get "/blame/*" do
        dolt.force_ref(params[:splat], "blame", "HEAD")
      end

      get "/history/*:*" do
        begin
          ref, path = params[:splat]
          dolt.history(repo, ref, path, (params[:commit_count] || 20).to_i)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      get "/history/*" do
        dolt.force_ref(params[:splat], "blame", "HEAD")
      end

      get "/refs" do
        begin
          dolt.refs(repo)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      get "/tree_history/*:*" do
        begin
          ref, path = params[:splat]
          dolt.tree_history(repo, ref, path)
        rescue Exception => err
          dolt.render_error(err, repo, ref)
        end
      end

      private
      attr_reader :repo, :lookup, :renderer

      def dolt
        @dolt ||= Dolt::Sinatra::Actions.new(self, lookup, renderer)
      end

      def force_ref(args, action, ref)
        redirect("/#{action}/#{ref}:" + args.join)
      end
    end
  end
end
