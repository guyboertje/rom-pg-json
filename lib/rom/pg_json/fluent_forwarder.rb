module ROM
  module PgJson
    class FluentForwarder < Module
      attr_reader :name

      def initialize(name, options = {})
        attr_reader name
        ivar = "@#{name}"

        define_method(:__proxy_target__) do
          instance_variable_get(ivar)
        end

        extend ClassMethods
      end

      module ClassMethods
        def fluent_forward(*methods)
        methods.each do |method|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{method}(*args, &block)
              __proxy_target__.__send__(:#{method}, *args, &block)
              self
            end
          RUBY
        end
      end
    end
  end
end
