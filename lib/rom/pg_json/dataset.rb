require 'arel'
require 'arel_pg_json'
require 'json'

module ROM
  module PgJson
    class Dataset
      attr_accessor :arel
      attr_reader :field, :filter, :sql

      def initialize(name)
        @arel = Arel::Table.new(name.to_sym, connection)
        @field = @arel[:serialised_data]
        @filter = nil
        @where = nil
      end

      def filter(path, value)
        refinement = Arel::Nodes::JsonHasDoubleArrow.new(@field, path)
        @filter = Arel::Nodes::Equality.new(refinement, value)
        self
      end

      def field(name)
        @field = @arel[name.to_sym]
        self
      end

      def each
        raw_connection.exec(sql).values.flatten.each do |result|
          yield JSON.parse(result)
        end
      end

      private

      def raw_connection
        connection.connection.raw_connection
      end

      def sql
        collector = @arel.project(@field)
        collector = collector.where(@where) if @where
        collector = collector.where(@filter) if @filter
        collector.to_sql
      end


    end
  end
end
