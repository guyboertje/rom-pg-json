module ROM
  module PgJson
    class Query
      def initialize(name, connection)
        puts '-------------------- Query initialize --------------------'
        @arel = Arel::Table.new(name.to_sym, connection)
        reset
      end

      def each(dataset, &block)
        dataset.each(sql, &block)
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

      def reset
        @json_field = @arel[:serialised_data]
        @json_criteria = nil
        @criteria = nil
        @limit = nil
        @offset = nil
        @results = []
      end

      def sql
        puts '-------------------- SQL --------------------'
        collector = @arel.project(@json_field)
        collector = collector.where(@criteria) if @criteria
        collector = collector.where(@json_criteria) if @json_criteria
        collector = collector.skip(@offset) if @offset
        collector = collector.take(@limit) if @limit
        collector.to_sql.tap{|s| puts s}
      end
    end
  end
end
