require 'rom/repository'

module ROM
  module PgJson
    class Repository < ROM::Repository
      attr_reader :tables

      def initialize(pg_connection)
        @connection = pg_connection
        @tables = {}
      end

      def [](name)
        tables.fetch(name)
      end

      def dataset(name)
        tables[name] = Dataset.new(name, @connection)
      end

      def dataset?(name)
        connection.table_exists?(name.to_s)
      end
    end
  end
end
