module ROM
  module PgJson
    class Query
      def initialize
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
        @json_criteria_path, @json_criteria_value = path, value
        self
      end

      def json_field(name)
        @json_field = name.to_sym
        self
      end

      def reset
        @json_field = :serialised_data
        @json_criteria_path = nil
        @json_criteria_value = nil
        @criteria = nil
        @limit = nil
        @offset = nil
      end

      def sql(name)
        puts '-------------------- SQL --------------------'
        table = Arel::Table.new(name)
        arel_json_field = table[@json_field]
        collector = table.project(arel_json_field)
        collector = collector.where(@criteria) if @criteria
        if @json_criteria_path && @json_criteria_value
          refinement = Arel::Nodes::JsonHashDoubleArrow.new(arel_json_field, @json_criteria_path)
          collector = collector.where(
            Arel::Nodes::Equality.new(refinement, @json_criteria_value)
          )
        end
        collector = collector.skip(@offset) if @offset
        collector = collector.take(@limit) if @limit
        collector = collector.order(table[:id].asc)
        collector.to_sql.tap{|s| puts s}
      end
    end
  end
end
