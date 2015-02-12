require 'arel'
require 'arel_pg_json'
require 'json'

module ROM
  module PgJson
    class Dataset
      def initialize(name, pool)
        @pool = pool
        @arel = Arel::Table.new(name.to_sym, @pool)
        @json_field = @arel[:serialised_data]
        @json_criteria = nil
        @criteria = nil
      end

      def criteria(criteria)
        @criteria = criteria
      end

      def json_criteria(path, value)
        refinement = Arel::Nodes::JsonHashDoubleArrow.new(@json_field, path)
        @json_criteria = Arel::Nodes::Equality.new(refinement, value)
      end

      def json_field(name)
        @json_field = @arel[name.to_sym]
        self
      end

      def each
        raw_connection.exec(sql).values.flatten.each do |result|
          yield result.nil? ? Hash.new : JSON.parse(result)
        end
      end

      private

      def sql
        collector = @arel.project(@json_field)
        collector = collector.where(@criteria) if @criteria
        collector = collector.where(@json_criteria) if @json_criteria
        collector.to_sql
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
