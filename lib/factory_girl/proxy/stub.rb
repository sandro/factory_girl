class Factory 
  class Proxy
    class Stub < Proxy #:nodoc:
      def initialize(klass)
        if klass && klass.respond_to?(:new)
          stub_class = Class.new(klass) do
            def self.name; superclass.name; end
            def self.inspect; superclass.inspect; end
            define_method(:initialize) {}
          end
        else
          stub_class = Object
        end
        @mock = stub_class.new
      end

      def get(attribute)
        @mock.send(attribute)
      end
      
      def set(attribute, value)
        unless @mock.respond_to?("attribute=")
          class << @mock; self end.send(:attr_accessor, attribute)
        end
        @mock.send("#{attribute}=", value)
      end
      
      def associate(name, factory, attributes)
        set(name, nil)
      end
      
      def result
        @mock      
      end
    end
  end
end
