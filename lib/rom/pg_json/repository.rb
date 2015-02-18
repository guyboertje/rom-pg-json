require 'rom/repository'

module ROM
  module PgJson
    class Repository < ROM::Repository
      def initialize(connection_pool, query_class)
        @connection = connection_pool
        @query_class = query_class
        build_schema
      end

      def [](name)
        build_dataset(name)
      end

      def dataset(name)
        build_dataset(name)
      end

      # def dataset?(name)
      #   puts '-------------------- dataset? --------------------'
      #   connection.table_exists?(name.to_s)
      # end

      private

      def build_schema
        @schema = connection.with_connection do |con|
          con.tables.select do |table|
            con.columns(table).any?{|col| col.type.to_s.start_with?('json')}
          end
        end
      end

      def build_dataset(name)
        Dataset.new(name, connection, @query_class)
      end
    end
  end
end
