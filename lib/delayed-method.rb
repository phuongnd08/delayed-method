require 'resque'
require 'active_support'

class DelayedMethod
  @queue = :delayed

  class << self
    include ActiveSupport::Inflector

    def perform(klass_name, instance_id, method, *args)
      if instance_id
        constantize(klass_name).find(instance_id).send(method, *args)
      else
        constantize(klass_name).send(method, *args)
      end
    end

    def enqueue(object, method, *args)
      raise ArgumentError.new("object does not respond to #{method}") unless object.respond_to?(method)
      if object.is_a? Class
        Resque.enqueue(DelayedMethod, object.name, nil, method, *args)
      elsif object.is_a? ActiveRecord::Base
        Resque.enqueue(DelayedMethod, object.class.name, object.id, method, *args)
      else
        raise ArgumentError.new("Only class and ActiveRecord resource are supported")
      end
    end
  end
end
