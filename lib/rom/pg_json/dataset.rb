require 'arel'
require 'arel_pg_json'
require 'json'

module ROM
  module PgJson
    class Dataset
      def initialize(name, pool)
        puts '-------------------- Dataset initialize --------------------'
        @pool = pool
        @arel = Arel::Table.new(name.to_sym, @pool)
        reset
      end

      def limit(amount)
        @limit = amount
        self
      end

      def offset(amount)
        @offset = amount
        self
      end

      def criteria(criteria)
        @criteria = criteria
        self
      end

      def json_criteria(path, value)
        refinement = Arel::Nodes::JsonHashDoubleArrow.new(@json_field, path)
        @json_criteria = Arel::Nodes::Equality.new(refinement, value)
        self
      end

      def json_field(name)
        @json_field = @arel[name.to_sym]
        self
      end

      def exec
        puts '-------------------- exec --------------------'
        @results = raw_connection.exec(sql).values.flatten
        self
      end

      def each
        exec
        @results.each do |result|
          yield result.nil? ? Hash.new : JSON.parse(result)
        end
      end

      def reset
        @json_field = @arel[:serialised_data]
        @json_criteria = nil
        @criteria = nil
        @limit = nil
        @offset = nil
        @results = []
      end

      private

      def sql
        collector = @arel.project(@json_field)
        collector = collector.where(@criteria) if @criteria
        collector = collector.where(@json_criteria) if @json_criteria
        collector = collector.skip(@offset) if @offset
        collector = collector.take(@limit) if @limit
        collector.to_sql.tap{|s| puts s}
      end

      def connection
        @pool.connection
      end

      def raw_connection
        connection.raw_connection
      end
    end
  end
end
