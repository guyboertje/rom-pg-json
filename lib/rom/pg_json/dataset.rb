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
          connection.raw_connection.exec(
            query.sql(@name)
          ).values.flatten.each do |result|
            block.call result.nil? ? Hash.new : JSON.parse(result)
          end
        end
      end

      def all(query)
        @pool.with_connection do |connection|
          connection.raw_connection.exec(
            query.sql(@name)
          ).values.flatten.map do |result|
            result.nil? ? Hash.new : JSON.parse(result)
          end
        end
      end

      def build_query
        query_class.new
      end
    end
  end
end
