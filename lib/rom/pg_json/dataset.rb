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
          exec_sql(connection, to_sql(query)).each do |result|
            block.call transform(result)
          end
        end
      end

      def all(query)
        @pool.with_connection do |connection|
          exec_sql(connection, to_sql(query)).map do |result|
            transform(result)
          end
        end
      end

      def all_string(query)
        @pool.with_connection do |connection|
          exec_sql(connection, to_sql(query)).map(&:to_s)
        end
      end

      def each_string(query, &block)
        @pool.with_connection do |connection|
          exec_sql(connection, to_sql(query)).map do |result|
            block.call result.to_s
          end
        end
      end

      def count(query)
        @pool.with_connection do |connection|
          exec_sql(connection, to_count_sql(query)).first.to_i
        end
      end

      def build_query
        @query_class.new
      end

      private

      def transform(result)
        result.nil? ? Hash.new : JSON.parse(result)
      end

      def exec_sql(con, sql)
        con.raw_connection.exec(sql).values.flatten
      end

      def to_sql(query)
        query.sql(@name)
      end

      def to_count_sql(query)
        query.count_sql(@name)
      end
    end
  end
end
