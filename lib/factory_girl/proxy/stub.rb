class Factory 
  class Proxy
    class Stub < Proxy #:nodoc:
      def initialize(klass)
        @mock = Object.new
      end
      
      def get(attribute)
        @mock.send(attribute)
      end
      
      def set(attribute, value)
        ivar = ivar_name(attribute)
        inner = class << @mock; self end

        unless @mock.respond_to?("#{ivar}=")
          inner.send(:attr_accessor, ivar)
        end

        unless @mock.respond_to?(attribute)
          inner.send(:define_method, attribute) do
            instance_variable_get(:"@#{ivar}")
          end
        end

        @mock.send("#{ivar}=", value)
      end

      def associate(name, factory, attributes)
        set(name, nil)
      end
      
      def result
        @mock      
      end

      private

      def ivar_name(symbol)
        # from ActiveSupport::Memoizable
        symbol.to_s.sub(/\?\Z/, '_query').sub(/!\Z/, '_bang').to_sym
      end
    end
  end
end
