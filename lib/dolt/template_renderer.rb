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
require "tilt"

module Dolt
  class TemplateRenderer
    def initialize(template_root, opt = {})
      @template_root = template_root
      @cache = {} if !opt.key?(:cache) || opt[:cache]
      @layout = opt[:layout]
      @type = opt[:type] || "erb"
      @context_class = Class.new
    end

    def helper(helper)
      helper = [helper] unless Array === helper
      helper.each { |h| @context_class.send(:include, h) }
    end

    def render(template, locals = {}, options = {})
      context = context_class.new
      content = load(template).render(context, locals)
      layout_tpl = options.key?(:layout) ? options[:layout] : layout

      if !layout_tpl.nil?
        content = load(layout_tpl).render(context, locals) { content }
      end

      content
    end

    private
    def load(name)
      file_name = File.join(template_root, "#{name}.#{type}")
      return cache[file_name] if cache && cache[file_name]
      template = Tilt.new(file_name)
      cache[file_name] = template if cache
      template
    end

    def template_root; @template_root; end
    def cache; @cache; end
    def layout; @layout; end
    def type; @type; end
    def context_class; @context_class; end
  end
end
