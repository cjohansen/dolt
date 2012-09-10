require "eventmachine"

module When
  class Promise
    def initialize(deferred = EM::DefaultDeferrable.new)
      @deferred = deferred
    end

    def callback(&block)
      @deferred.callback(&block)
      self
    end

    def errback(&block)
      @deferred.errback(&block)
      self
    end
  end

  class Resolver
    def initialize(deferred = EM::DefaultDeferrable.new)
      @deferred = deferred
      @resolved = false
    end

    def resolve(*args)
      mark_resolved
      @deferred.succeed(*args)
    end

    def reject(*args)
      mark_resolved
      @deferred.fail(*args)
    end

    private
    def mark_resolved
      raise StandardError.new("Already resolved") if @resolved
      @resolved = true
    end
  end

  class Deferred
    attr_reader :resolver, :promise

    def initialize
      deferred = EM::DefaultDeferrable.new
      @resolver = Resolver.new(deferred)
      @promise = Promise.new(deferred)
    end

    def resolve(*args)
      @resolver.resolve(*args)
    end

    def reject(*args)
      @resolver.reject(*args)
    end

    def callback(&block)
      @promise.callback(&block)
    end

    def errback(&block)
      @promise.errback(&block)
    end

    def self.resolved(value)
      d = self.new
      d.resolve(vaule)
      d
    end

    def self.rejected(value)
      d = self.new
      d.reject(vaule)
      d
    end
  end

  module Functions
    def deferred(val)
      return val if val.respond_to?(:callback) && val.respond_to?(:errback)
      Deferred.resolved(val).promise
    end
  end
end
