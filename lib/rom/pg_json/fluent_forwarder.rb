module ROM
  module PgJson
    # with thanks to solnic/charlatan
    class FluentForwarder < Module
      attr_reader :name

      def initialize(name, options = {})
        attr_reader name
        ivar = "@#{name}"

        define_method(:__proxy_target__) do
          instance_variable_get(ivar)
        end

        include Methods
      end

      module Methods
        def respond_to_missing?(method_name, _include_private = false)
          __proxy_target__.respond_to?(method_name, _include_private) || super
        end

        def method_missing(method_name, *args, &block)
          if __proxy_target__.respond_to?(method_name)
            __proxy_target__.public_send(method_name, *args, &block)
            self
          else
            super
          end
        end
      end
    end
  end
end
