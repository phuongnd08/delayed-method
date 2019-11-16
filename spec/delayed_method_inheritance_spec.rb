require File.dirname(__FILE__) + '/spec_helper'
require 'active_record'

describe "DelayedMethod inheritance" do
  describe "enqueue and perform" do
    class CustomDelayedMethod < DelayedMethod
      @queue = :delayed

      def self.perform(*args)
        before_hook
        super
        after_hook
      end

      def self.before_hook
      end

      def self.after_hook
      end
    end

    class TestClass2
      def self.execute(name, value)

      end
    end

    context "for class object" do
      it "queues a job to cause execution to happen" do
        TestClass2.should_receive(:execute).with("sample", "another_sample")
        CustomDelayedMethod.enqueue(TestClass2, :execute, "sample", "another_sample")
        klass, args = Resque.reserve(:delayed)
        klass.perform(*args)
      end

      it "queues CustomDelayedMethod as worker" do
        CustomDelayedMethod.enqueue(TestClass2, :execute, "sample", "another_sample")
        klass, args = Resque.reserve(:delayed)
        klass.payload_class.should eq(CustomDelayedMethod)
      end

      it "executes correctly with extra hooks" do
        CustomDelayedMethod.should_receive(:before_hook)
        CustomDelayedMethod.should_receive(:after_hook)
        CustomDelayedMethod.enqueue(TestClass2, :execute, "sample", "another_sample")
        klass, args = Resque.reserve(:delayed)
        klass.perform(*args)
      end
    end

    context "for active record instance" do
      it "queues a job to cause execution to happen" do
        armodel = mock_armodel
        armodel.should_receive(:execute).with("sample", "another_sample")
        CustomDelayedMethod.enqueue(armodel, :execute, "sample", "another_sample")
        klass, args = Resque.reserve(:delayed)
        klass.perform(*args)
      end

      it "queues CustomDelayedMethod as worker" do
        armodel = mock_armodel
        CustomDelayedMethod.enqueue(armodel, :execute, "sample", "another_sample")
        klass, args = Resque.reserve(:delayed)
        klass.payload_class.should eq(CustomDelayedMethod)
      end
    end
  end
end

def mock_armodel
  mock(ActiveRecord::Base, { :id => 1, :execute => true }).tap do |armodel|
    armodel.should_receive(:is_a?).with(Class).and_return(false)
    armodel.should_receive(:is_a?).with(ActiveRecord::Base).and_return(true)
    armodel.should_receive(:class).and_return ActiveRecord::Base
    armodel.stub(:persisted?).and_return true
    ActiveRecord::Base.stub(:find).with(1).and_return armodel
  end
end
