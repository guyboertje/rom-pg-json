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
        @wheres = []
        table = Arel::Table.new(name)
        arel_json_field = table[@json_field]
        select = project(table, arel_json_field)
        add_criteria(select, table)
        add_json_criteria(select, arel_json_field)
        select.where(Arel::Nodes::And.new(@wheres)) if !@wheres.size.zero?
        select.skip(@offset) if @offset
        select.take(@limit) if @limit
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

      def add_criteria(select, table)
        # this is very simple
        # criteria can be a SQL string or a Hash of field: value
        # where value is a Range, Array or Value
        # and the contents of value are compatible withn the fields db datatype
        # if you need 'less than' use a Range for now
        # updated_at: Range.new((Date.today - 7).midnight, Date.today.succ.midnight - 1)
        # so NOT {field: [Range.new(3,6), 8, 9]} -> (field BETWEEN 3 AND 6) OR field IN (2,8)
        if String === @criteria
          @wheres.push Arel.sql(@criteria)
        elsif Hash === @criteria
          @criteria.each do |k,v|
            @wheres.push build_node(table[k], v)
          end
        end
      end

      def add_json_criteria(select, field)
        if @json_criteria_path && @json_criteria_value
          path_node = Arel::Nodes::JsonHashDoubleArrow.new(field, @json_criteria_path)
          @wheres.push Arel::Nodes::Equality.new(path_node, @json_criteria_value)
        end
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

      def build_node(attribute, value)
        case value
        when Range, Array
          Arel::Nodes::Grouping.new(attribute.in(value))
        else
          attribute.eq(value)
        end
      end
    end
  end
end


