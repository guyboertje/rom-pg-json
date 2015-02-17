require 'arel'
require 'arel_pg_json'
require 'json'

module ROM
  module PgJson
    class Dataset
      def initialize(name, connection_pool, query_class)
        @name, @pool = name, connection_pool
        @query_class = query_class
      end

      def each(query, &block)
        @pool.with_connection do |connection|
          exec_sql(connection, query).each do |result|
            block.call result.nil? ? Hash.new : JSON.parse(result)
          end
        end
      end

      def all(query)
        @pool.with_connection do |connection|
          exec_sql(connection, query).map do |result|
            result.nil? ? Hash.new : JSON.parse(result)
          end
        end
      end

      def count(query)
        @pool.with_connection do |connection|
          exec_sql(connection, query).first.to_i
        end
      end

      def build_query
        @query_class.new
      end

      private

      def exec_sql(con, query)
        sql = query.sql(@name)
        con.raw_connection.exec(sql).values.flatten
      end
    end
  end
end
