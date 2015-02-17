require 'rom/repository'

module ROM
  module PgJson
    class Repository < ROM::Repository
      def initialize(connection_pool, query_class)
        @connection = connection_pool
        @query_class = query_class
      end

      def [](name)
        build_dataset(name)
      end

      def dataset(name)
        build_dataset(name)
      end

      def dataset?(name)
        puts '-------------------- dataset? --------------------'
        connection_pool.table_exists?(name.to_s)
      end

      private

      def build_dataset(name)
        Dataset.new(name, connection, @query_class)
      end
    end
  end
end
