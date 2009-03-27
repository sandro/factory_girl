require 'test_helper'

class StubProxyTest < Test::Unit::TestCase
  context "the stub proxy" do
    setup do
      @proxy = Factory::Proxy::Stub.new(@class)
    end
    
    context "when asked to associate with another factory" do
      setup do
        Factory.stubs(:create)
        @proxy.associate(:owner, :user, {})
      end

      should "not set a value for the association" do
        assert_nil @proxy.result.owner
      end
    end

    should "return nil when building an association" do
      assert_nil @proxy.association(:user)
    end

    should "not call Factory.create when building an association" do
      Factory.expects(:create).never
      assert_nil @proxy.association(:user)
    end

    should "always return nil when building an association" do
      @proxy.set(:association, 'x')
      assert_nil @proxy.association(:user)
    end

    context "result object" do
      should "return a generic object when stubbing a nil class" do
        assert_kind_of Object, @proxy.result
      end

      context "for a specific class" do
        setup do
          @my_class = Class.new do
            def self.inspect; 'my_class' end
            def self.to_s; 'my_class' end
          end
          @proxy = Factory::Proxy::Stub.new @my_class
          @result = @proxy.result
        end

        should "return instance of the class being stubbed" do
          assert_kind_of @my_class, @result
        end

        should "return superclass to_s" do
          assert_equal @my_class.to_s, @result.class.to_s
        end

        should "return superclass inspect" do
          assert_equal @my_class.inspect, @result.class.inspect
        end

        should "override superclass initialize" do
          my_raise_class = Class.new do
            def initialize
              raise "limited initialize"
            end
          end
          assert_nothing_raised do
            Factory::Proxy::Stub.new my_raise_class
          end
        end
      end
    end

    context "after setting an attribute" do
      setup do
        @proxy.set(:attribute, 'value')
      end

      should "add a stub to the resulting object" do
        assert_equal 'value', @proxy.attribute
      end

      should "return that value when asked for that attribute" do
        assert_equal 'value', @proxy.get(:attribute)
      end
    end    
  end
end
