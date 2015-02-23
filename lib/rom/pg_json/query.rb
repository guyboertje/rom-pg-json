require 'arel'
require 'arel_pg_json'

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
        @json_criterias.push([path, value.to_s])
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
        @json_criterias = []
        @criterias = []
        @limit = nil
        @offset = nil
        @count = false
        @order_spec = {id: :asc}
      end

      def sql(name)
        table = Arel::Table.new(name)
        arel_json_field = table[@json_field]
        select = project(table, arel_json_field)
        wheres = collect_criteria(table) +
                 collect_json_criteria(arel_json_field)
        select.where(Arel::Nodes::And.new(wheres)) if !wheres.size.zero?
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
        @json_criterias.each_with_object([]) do |(path, value), array|
          array.push  Arel::Nodes::Equality.new(
                        Arel::Nodes::JsonHashDoubleArrow.new(field, path),
                        value
                      )
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


