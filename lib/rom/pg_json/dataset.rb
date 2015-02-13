require 'arel'
require 'arel_pg_json'
require 'json'

module ROM
  module PgJson
    class Dataset
      def initialize(name, connection_proc)
        puts '-------------------- Dataset initialize --------------------'
        @name, @connection_proc = name, connection_proc
      end

      def exec
        puts '-------------------- exec --------------------'
        raw_connection.exec(sql).values.flatten
      end

      def each(sql, &blk)
        exec(sql).each do |result|
          blk.call result.nil? ? Hash.new : JSON.parse(result)
        end
      end

      def build_query
        Query.new(@name, pool)
      end

      private

      def pool
        @connection_proc.call
      end

      def raw_connection
        pool.connection.raw_connection
      end
    end
  end
end
