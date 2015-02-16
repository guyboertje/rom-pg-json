require 'rom/repository'

module ROM
  module PgJson
    class Repository < ROM::Repository
      def initialize(connection_pool)
        @connection = connection_pool
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
        Dataset.new(name, connection)
      end
    end
  end
end
