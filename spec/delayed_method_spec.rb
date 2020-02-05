require File.dirname(__FILE__) + '/spec_helper'
require 'active_record'

describe DelayedMethod do
  describe "debugging get/set" do
    it "works" do
      DelayedMethod.debugging = true
      expect(DelayedMethod.debugging).to eq true
      DelayedMethod.debugging = nil
    end
  end

  describe "enqueue and perform" do
    context "object does not respond method" do
      it "raises exception" do
        expect {
          DelayedMethod.enqueue(Object, :non_existent_method)
        }.to raise_error
      end
    end

    context "object responds to method" do
      class TestClass
        def self.execute(name, value)

        end
      end

      context "for class object" do
        it "queues a job to cause execution to happen" do
          TestClass.should_receive(:execute).with("sample", "another_sample")
          DelayedMethod.enqueue(TestClass, :execute, "sample", "another_sample")
          klass, args = Resque.reserve(:delayed)
          klass.perform(*args)
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
      context "for active record instance" do
        it "queues a job to cause execution to happen" do
          armodel = mock_armodel
          armodel.should_receive(:execute).with("sample", "another_sample")
          DelayedMethod.enqueue(armodel, :execute, "sample", "another_sample")
          klass, args = Resque.reserve(:delayed)
          klass.perform(*args)
        end

        context "object is not persisted" do
          it "raises exception with identifying info" do
            armodel = mock_armodel
            armodel.stub(:some_method)
            armodel.stub(:persisted?).and_return(false)
            expect {
              DelayedMethod.enqueue(armodel, :some_method)
            }.to raise_error(ArgumentError, /Base.*some_method/)
          end
        end
      end
    end
  end
end
