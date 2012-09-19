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
module Dolt
  class Merger
    def initialize(objects)
      @objects = objects
    end

    def <<(object)
      @objects << object
    end

    def method_missing(method, *args, &block)
      object = provider(method)
      return super if object.nil?
      object.send(method, *args, &block)
    end

    def respond_to?(method)
      !provider(method).nil?
    end

    private
    def provider(method)
      @objects.find { |h| h.respond_to?(method) }
    end
  end
end
