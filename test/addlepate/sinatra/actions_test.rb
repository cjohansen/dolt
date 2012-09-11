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
require "addlepate/sinatra/actions"

class DummySinatraApp
  include Addlepate::Sinatra::Actions
  attr_reader :actions, :renderer

  def initialize(actions, renderer)
    @actions = actions
    @renderer = renderer
  end

  def body(str = nil)
    @body = str if !str.nil?
    @body
  end

  def response
    @response ||= {}
  end
end

class Renderer
  def initialize(body = ""); @body = body; end

  def render(action, data)
    @action = action
    @data = data
    @body
  end
end

class Actions
  attr_reader :repo, :ref, :path

  def blob(repo, ref, path)
    @repo = repo
    @ref = ref
    @path = path
    yield nil, { :ref => ref, :repository => repo, :blob => "Blob" }
  end
end

describe Addlepate::Sinatra::Actions do
  describe "#blob" do
    it "delegates to actions" do
      actions = Actions.new
      app = DummySinatraApp.new(actions, Renderer.new)
      app.blob("gitorious", "master", "app/models/repository.rb")

      assert_equal "gitorious", actions.repo
      assert_equal "master", actions.ref
      assert_equal "app/models/repository.rb", actions.path
    end

    it "renders the blob template as html" do
      app = DummySinatraApp.new(Actions.new, Renderer.new("Blob"))
      app.blob("gitorious", "master", "app/models/repository.rb")

      assert_equal "text/html", app.response["Content-Type"]
      assert_equal "Blob", app.body
    end
  end
end
