require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Factory::Proxy::Stub do
  before do
    @class = "class"
    @instance = "instance"
    stub(@class).new { @instance }
    stub(@instance, :id=)
    stub(@instance).id { 42 }
    stub(@instance).reload { @instance.connection.reload }

    @stub = Factory::Proxy::Stub.new(@class)
  end

  it "should not be a new record" do
    @stub.result.should_not be_new_record
  end

  it "should not be able to connect to the database" do
    lambda { @stub.result.reload }.should raise_error(RuntimeError)
  end

  describe "when a user factory exists" do
    before do
      @user = "user"
      stub(Factory).stub(:user, {}) { @user }
    end

    describe "when asked to associate with another factory" do
      before do
        stub(@instance).owner { @user }
        mock(Factory).stub(:user, {}) { @user }
        mock(@stub).set(:owner, @user)

        @stub.associate(:owner, :user, {})
      end

      it "should set a value for the association" do
        @stub.result.owner.should == @user
      end
    end

    it "should return the association when building one" do
      mock(Factory).create.never
      @stub.association(:user).should == @user
    end

    it "should return the actual instance when asked for the result" do
      @stub.result.should == @instance
    end
  end

  describe "with an existing attribute" do
    before do
      @value = "value"
      mock(@instance).send(:attribute) { @value }
      mock(@instance).send(:attribute=, @value)
      @stub.set(:attribute, @value)
    end

    it "should to the resulting object" do
      @stub.attribute.should == 'value'
    end

    it "should return that value when asked for that attribute" do
      @stub.get(:attribute).should == @value
    end
  end

  describe "making the instance ActiveRecord compatible" do
    before do
      @class = Class.new { def initialize(arguments);end }
      @next_id = Factory::Proxy::Stub.send(:class_variable_get, '@@next_id') + 1
    end

    context "when the instance has an id setter" do
      before do
        @class.class_eval do
          def id=(value);end
        end
      end

      it "sets id to the next id" do
        mock.proxy(@class).allocate do |instance|
          mock(instance).id=(@next_id)
          instance
        end
        Factory::Proxy::Stub.new(@class)
      end
    end

    context "when the instance does not have an id setter" do
      it "does not set the id" do
        stub = Factory::Proxy::Stub.new(@class)
        stub.result.should_not have_received(:id=).with(@next_id)
      end
    end
  end

  describe "when object instantiation requires arguments" do
    before do
      @class = Class.new { def initialize(arguments);end }
    end

    it "does not raise ArgumentError" do
      expect {
        Factory::Proxy::Stub.new(@class)
      }.to_not raise_error(ArgumentError)
    end

    it "instantiates the object" do
      stub = Factory::Proxy::Stub.new(@class)
      stub.result.should be_instance_of(@class)
    end
  end
end
