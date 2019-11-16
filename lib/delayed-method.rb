require 'resque'
require 'active_support'

class DelayedMethod
  @queue = :delayed

  class << self
    def perform(klass_name, instance_id, method, *args)
      puts "<#{klass_name}##{instance_id}>##{method}#{args}"
      if instance_id
        Object.const_get(klass_name).find(instance_id).send(method, *args)
      else
        Object.const_get(klass_name).send(method, *args)
      end
    end

    def enqueue(object, method, *args)
      ensure_proper_call(object, method) do |klass, id|
        Resque.enqueue(self, klass, id, method, *args)
      end
    end

    def enqueue_to(queue, object, method, *args)
      ensure_proper_call(object, method) do |klass, id|
        Resque.enqueue_to(queue, self, klass, id, method, *args)
      end
    end


    def enqueue_at(time, object, method, *args)
      ensure_proper_call(object, method) do |klass, id|
        if Resque.respond_to?(:enqueue_at)
          Resque.enqueue_at(time, self, klass, id, method, *args)
        else
          raise "resque-scheduler need to be included for this to work"
        end
      end
    end

    private
    def ensure_proper_call(object, method)
      raise ArgumentError.new("object does not respond to #{method}") unless object.respond_to?(method)
      if object.is_a? Class
        yield object.name, nil
      elsif object.is_a? ActiveRecord::Base
        raise ArgumentError.new("object #{object.class}:#{object.id}##{method} needs to be persisted #{caller}") unless object.persisted?
        yield object.class.name, object.id
      else
        raise ArgumentError.new("Only class and ActiveRecord resource are supported")
      end
    end
  end
end
