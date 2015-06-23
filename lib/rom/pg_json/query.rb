require 'arel'
require 'arel_pg_json'

if !Arel::Nodes.respond_to?(:build_quoted)
  module Arel
    module Nodes
      def self.build_quoted(val)
        return val if val.start_with?(?') && val.end_with?(?')
        SqlLiteral.new("'#{val}'")
      end
    end
  end
end

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
        @criterias.push criteria
        self
      end

      def json_criteria(path, value)
        @json_criterias.push([path, value])
        self
      end

      def json_expression_criteria(path, op, value)
        @json_expression_criterias.push([path, op, value])
        self
      end

      def json_expression_time(path, values, cast_as = 'int8')
        @json_expression_times.push([path, values, cast_as])
        self
      end

      def json_order_by(spec)
        @json_order_spec = spec
        self
      end

      def json_field(name)
        @json_field = name.to_sym
        self
      end

      def order_by(spec)
        @order_spec = spec
        self
      end

      def reset
        @json_field = :serialised_data
        @json_criterias = []
        @json_expression_criterias = []
        @json_expression_times = []
        @json_order_spec = {}
        @criterias = []
        @limit = nil
        @offset = nil
        @count = false
        @order_spec = {}
      end

      def sql(name)
        table = Arel::Table.new(name)
        arel_json_field = table[@json_field]
        select = project(table, arel_json_field)
        wheres = collect_criteria(table) +
                 collect_json_criteria(arel_json_field) +
                 collect_json_expression_criteria(arel_json_field) +
                 collect_json_expression_times(arel_json_field)
        select.where(Arel::Nodes::And.new(wheres)) if !wheres.size.zero?
        select.skip(@offset) if @offset
        select.take(@limit) if @limit
        default_ordering
        add_ordering(select,
          ordering_to_arel(table),
          json_ordering_to_arel(arel_json_field)
        )
        build_sql(select)
      end

      def count_sql(name)
        @count = true
        sql(name)
      ensure
        @count = false
      end

      private

      def quoted_node(val)
        Arel::Nodes.build_quoted(val)
      end

      def unquoted_node(val)
        Arel::Nodes.SqlLiteral.new(val)
      end

      def default_ordering
        if @order_spec.empty? && @json_order_spec.empty?
          @order_spec[:id] = :asc
        end
      end

      def json_ordering_to_arel(arel_json_field)
        return [] if @count
        @json_order_spec.map do |path, dir|
          order_node = Arel::Nodes::Ascending.new(
            Arel::Nodes::JsonDashArrow.new(arel_json_field, quoted_node(path))
          )
          dir.to_s.upcase.start_with?('DESC') ?
            order_node.reverse : order_node
        end
      end

      def ordering_to_arel(table)
        return [] if @count
        @order_spec.map do |field, dir|
          order_node = Arel::Nodes::Ascending.new(
            table[field.to_sym]
          )
          dir.to_s.upcase.start_with?('DESC') ?
            order_node.reverse : order_node
        end
      end

      def add_ordering(select, order_spec, json_spec)
        return if @count
        select.order *order_spec.concat(json_spec)
      end

      def collect_criteria(table)
        # this is very simple
        # criteria can be a SQL string or a Hash of field: value
        # where value is a Range, Array or Value
        # and the contents of value are compatible withn the fields db datatype
        # if you need 'less than' use a Range for now
        # updated_at: Range.new((Date.today - 7).midnight, Date.today.succ.midnight - 1)
        # so NOT {field: [Range.new(3,6), 8, 9]} -> (field BETWEEN 3 AND 6) OR field IN (2,8)
        @criterias.each_with_object([]) do |criteria, array|
          if String === criteria
            array.push Arel.sql(criteria)
          elsif Hash === criteria
            criteria.each do |k,v|
              array.push build_node(table[k], v)
            end
          end
        end
      end

      def collect_json_criteria(field)
        return [] if @json_criterias.size.zero?
        json = Hash[@json_criterias].to_json
        [Arel::Nodes::JsonbAtArrow.new(field, quoted_node(json))]
      end

      def collect_json_expression_criteria(field)
        return [] if @json_expression_criterias.size.zero?
        @json_expression_criterias.each_with_object([]) do |(path, op, value), array|
          array.push arel_node_for_expression(field, path, op, value)
        end
      end

      def arel_node_for_expression(field, path, op, value)
        outer_node = arel_node_for(op)
        quoted_path = quoted_node(path)
        if Array === value
          lhs = Arel::Nodes::JsonDashDoubleArrow.new(field, quoted_path)
          inter = value.join(',').prepend("'{").concat("}'::text[]")
          function = (op == '!=') ? 'ALL' : 'ANY'
          rhs = Arel::Nodes::NamedFunction.new(function, [Arel.sql(inter)])
        else
          lhs = Arel::Nodes::JsonDashArrow.new(field, quoted_path)
          rhs = quoted_node(value)
        end
        outer_node.new(lhs, rhs)
      end

      def collect_json_expression_times(field)
        return [] if @json_expression_times.size.zero?
        @json_expression_times.each_with_object([]) do |(path, values, cast_as), array|
          node_class, right_node = arel_nodes_for_times(values)
          array.push node_class.new(
            Arel::Nodes::CastJson.new(
              Arel::Nodes::JsonDashDoubleArrow.new(field, quoted_node(path)),
              cast_as
            ), right_node
          )
        end
      end

      def arel_nodes_for_times(values)
        val1, val2 = Array(values)
        if !val2.nil?
          if String === val2
            [arel_node_for(val2), val1]
          else
            [Arel::Nodes::Between, Arel::Nodes::And.new([val1, val2])]
          end
        else
          [Arel::Nodes::Equality, val1]
        end
      end

      def build_sql(select)
        str = select.to_sql
        if @count
          str.prepend('SELECT  COUNT(count_column) FROM (').concat(') subquery_for_count')
        end
        # str.tap{|s| puts s}
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

      def arel_node_for(op)
        return Arel::Nodes::JsonbQuestionAnd   if op.start_with?('&') # might be &&
        return Arel::Nodes::JsonbQuestionOr    if op.start_with?('|') # might be ||
        return Arel::Nodes::JsonbQuestion      if op == '?'

        return Arel::Nodes::GreaterThan        if op == '>'
        return Arel::Nodes::GreaterThanOrEqual if op == '>='
        return Arel::Nodes::LessThan           if op == '<'
        return Arel::Nodes::LessThanOrEqual    if op == '<='
        return Arel::Nodes::NotEqual           if op == '!='

        Arel::Nodes::Equality
      end
    end
  end
end

