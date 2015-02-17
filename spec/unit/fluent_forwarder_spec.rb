require 'spec_helper'
require 'rom/pg_json/fluent_forwarder'

describe ROM::PgJson::FluentForwarder do
  let(:other_class) do
    Class.new do
      def foo(arg)
        @foo = arg
      end
      def bar(arg)
        @bar = arg
      end
      def to_s
        "foo: '#{@foo}', bar: '#{@bar}'"
      end
    end
  end

  let(:parent) do
    Class.new do
      def respond_to_missing?(method_name, _include_private = false)
        @extra.respond_to?(method_name, _include_private) || super
      end

      def method_missing(method_name, *args, &block)
        if @extra.respond_to?(method_name)
          @extra.public_send(method_name, *args, &block)
        else
          super
        end
      end
    end
  end

  let(:test_class) do
    Class.new(parent) do
      include ROM::PgJson::FluentForwarder.new(:forward_to)

      def initialize(extra, forward_to_class)
        @extra = extra
        @forward_to = forward_to_class.new
      end

      def inspect
        "#<TestClass  @extra='#{@extra.inspect}' forward_to=#{@forward_to}>"
      end

      def forward_to
        @forward_to
      end
    end
  end

  let(:fft) { test_class.new({stuff: 'stuff'}, other_class) }

  it 'adds reader method for target object' do
    expect(fft.forward_to).not_to be_nil
  end

  it 'forwards messages' do
    expect(fft.inspect).to eq("#<TestClass  @extra='{:stuff=>\"stuff\"}' forward_to=foo: '', bar: ''>")
    fft.foo('fooing')
    fft.bar('barring')
    fft.update(bits: 'bits')
    expect(fft.inspect).to eq("#<TestClass  @extra='{:stuff=>\"stuff\", :bits=>\"bits\"}' forward_to=foo: 'fooing', bar: 'barring'>")
  end
end
