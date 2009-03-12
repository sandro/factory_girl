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

    should "return a mock object when asked for the result" do
      assert_kind_of Object, @proxy.result
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

      should "create a setter" do
        assert_equal true, @proxy.result.respond_to?(:attribute=)
      end

      should "change the attribute" do
        obj = @proxy.result
        obj.attribute = 'new value'
        assert_equal 'new value', obj.attribute
      end

      context "responds to query methods" do
        setup do
          @proxy.set(:query?, 'value')
        end

        should "return the value given" do
          assert_equal 'value', @proxy.get(:query?)
        end

        should "define a special instance variable" do
          assert_equal true, @proxy.result.instance_variables.include?("@query_query")
        end
      end

      context "supports bang methods" do
        setup do
          @proxy.set(:bang!, 'value')
        end

        should "return the value given" do
          assert_equal 'value', @proxy.get(:bang!)
        end

        should "define a special instance variable" do
          assert_equal true, @proxy.result.instance_variables.include?("@bang_bang")
        end
      end
    end
  end
end
