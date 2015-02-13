require 'rom/repository'

module ROM
  module PgJson
    class Repository < ROM::Repository
      def initialize(connection_proc)
        @connection = connection_proc
      end

      def [](name)
        build_dataset(name)
      end

      def dataset(name)
        build_dataset(name)
      end

      def dataset?(name)
        puts '-------------------- dataset? --------------------'
        connection.call.table_exists?(name.to_s)
      end

      def schema
        connection.call.tables
      end

      private

      def build_dataset(name)
        puts '-------------------- build_dataset --------------------'
        Dataset.new(name, connection)
      end
    end
  end
end
