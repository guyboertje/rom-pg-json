require 'pg'
require 'uri'

require 'rom/repository'

require 'rom/pg_json/dataset'
require 'rom/pg_json/relation'

module Rom
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
        tables[name] = Dataset.new(name)
      end

      def dataset?(name)
        connection.table_exists?(name.to_s)
      end

      private

      def split_name(name)

      end
    end
  end
end
