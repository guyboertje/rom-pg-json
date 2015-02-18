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

      def order_by(spec)
        @order_spec = spec
      end

      def reset
        @json_field = :serialised_data
        @json_criteria_path = nil
        @json_criteria_value = nil
        @criteria = nil
        @limit = nil
        @offset = nil
        @count = false
        @order_spec = {id: :asc}
      end

      def sql(name)
        table = Arel::Table.new(name)
        arel_json_field = table[@json_field]
        select = project(table, arel_json_field)
        select.where(@criteria) if @criteria
        select.skip(@offset) if @offset
        select.take(@limit) if @limit
        add_json_criteria(select, arel_json_field)
        add_ordering(select, table)
        build_sql(select).tap{|s| puts s}
      end

      def count_sql(name)
        @count = true
        sql(name)
      ensure
        @count = false
      end

      private

      def add_ordering(select, table)
        return if @count
        @order_spec.each do |field, dir|
          select.order(table[field].send(dir))
        end
      end

      def add_json_criteria(select, field)
        return unless @json_criteria_path && @json_criteria_value
        path_node = Arel::Nodes::JsonHashDoubleArrow.new(field, @json_criteria_path)
        equals_node = Arel::Nodes::Equality.new(path_node, @json_criteria_value)
        select.where(equals_node)
      end

      def build_sql(select)
        str = select.to_sql
        if @count
          str.prepend('SELECT  COUNT(count_column) FROM (').concat(') subquery_for_count')
        end
        str
      end

      def project(table, arel_json_field)
        if @count
          table.project(Arel::Nodes::SqlLiteral.new('1').as('count_column'))
        else
          table.project(arel_json_field)
        end
      end
    end
  end
end


