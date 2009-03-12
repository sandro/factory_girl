require 'test_helper'

class IntegrationTest < Test::Unit::TestCase

  def setup
    Factory.define :user, :class => 'user' do |f|
      f.first_name 'Jimi'
      f.last_name  'Hendrix'
      f.admin       false
      f.email {|a| "#{a.first_name}.#{a.last_name}@example.com".downcase }
    end

    Factory.define Post, :default_strategy => :attributes_for do |f|
      f.name   'Test Post'
      f.association :author, :factory => :user
    end

    Factory.define :admin, :class => User do |f|
      f.first_name 'Ben'
      f.last_name  'Stein'
      f.admin       true
      f.sequence(:username) { |n| "username#{n}" }      
      f.email { Factory.next(:email) }
    end
    
    Factory.define :guest, :parent => :user do |f|
      f.last_name 'Anonymous'
      f.username  'GuestUser'
    end
    
    Factory.sequence :email do |n|
      "somebody#{n}@example.com"
    end
  end

  def teardown
    Factory.factories.clear
  end

  context "a generated attributes hash" do

    setup do
      @attrs = Factory.attributes_for(:user, :first_name => 'Bill')
    end

    should "assign all attributes" do
      assert_equal [:admin, :email, :first_name, :last_name],
                   @attrs.keys.sort {|a, b| a.to_s <=> b.to_s }
    end

    should "correctly assign lazy, dependent attributes" do
      assert_equal "bill.hendrix@example.com", @attrs[:email]
    end

    should "override attrbutes" do
      assert_equal 'Bill', @attrs[:first_name]
    end

    should "not assign associations" do
      assert_nil Factory.attributes_for(:post)[:author]
    end

  end

  context "a built instance" do

    setup do
      @instance = Factory.build(:post)
    end

    should "not be saved" do
      assert @instance.new_record?
    end

    should "assign associations" do
      assert_kind_of User, @instance.author
    end

    should "save associations" do
      assert !@instance.author.new_record?
    end

    should "not assign both an association and its foreign key" do
      assert_equal 1, Factory.build(:post, :author_id => 1).author_id
    end

  end

  context "a created instance" do

    setup do
      @instance = Factory.create('post')
    end

    should "be saved" do
      assert !@instance.new_record?
    end

    should "assign associations" do
      assert_kind_of User, @instance.author
    end

    should "save associations" do
      assert !@instance.author.new_record?
    end

  end
  
  context "a generated mock instance" do

    setup do
      @stub = Factory.stub(:user, :first_name => 'Bill', :adult? => false, :suspend! => true)
    end

    should "assign all attributes" do
      [:admin, :email, :first_name, :last_name, :adult?, :suspend!].each do |attr|
        assert_not_nil @stub.send(attr)     
      end
    end

    should "correctly assign lazy, dependent attributes" do
      assert_equal "bill.hendrix@example.com", @stub.email
    end

    should "override attrbutes" do
      assert_equal 'Bill', @stub.first_name
    end

    should "not assign associations" do
      assert_nil Factory.stub(:post).author
    end

  end  
  
  context "an instance generated by a factory with a custom class name" do

    setup do
      @instance = Factory.create(:admin)
    end

    should "use the correct class name" do
      assert_kind_of User, @instance
    end

    should "use the correct factory definition" do
      assert @instance.admin?
    end

  end
  
  context "an instance generated by a factory that inherits from another factory" do
    setup do
      @instance = Factory.create(:guest)    
    end
    
    should "use the class name of the parent factory" do
      assert_kind_of User, @instance
    end
    
    should "have attributes of the parent" do
      assert_equal 'Jimi', @instance.first_name
    end
    
    should "have attributes defined in the factory itself" do
      assert_equal 'GuestUser', @instance.username
    end
    
    should "have attributes that have been overriden" do
      assert_equal 'Anonymous', @instance.last_name
    end
  end

  context "an attribute generated by a sequence" do

    setup do
      @email = Factory.attributes_for(:admin)[:email]
    end

    should "match the correct format" do
      assert_match /^somebody\d+@example\.com$/, @email
    end

    context "after the attribute has already been generated once" do

      setup do
        @another_email = Factory.attributes_for(:admin)[:email]
      end

      should "match the correct format" do
        assert_match /^somebody\d+@example\.com$/, @email
      end

      should "not be the same as the first generated value" do
        assert_not_equal @email, @another_email
      end

    end

  end
  
  context "an attribute generated by an in-line sequence" do

    setup do
      @username = Factory.attributes_for(:admin)[:username]
    end

    should "match the correct format" do
      assert_match /^username\d+$/, @username
    end

    context "after the attribute has already been generated once" do

      setup do
        @another_username = Factory.attributes_for(:admin)[:username]
      end

      should "match the correct format" do
        assert_match /^username\d+$/, @username
      end

      should "not be the same as the first generated value" do
        assert_not_equal @username, @another_username
      end

    end

  end  
  
  context "a factory with a default strategy specified" do
    should "generate instances according to the strategy" do
      assert_kind_of Hash, Factory(:post) 
    end
  end

end
