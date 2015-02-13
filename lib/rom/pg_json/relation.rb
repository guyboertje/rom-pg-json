module ROM
  module PgJson
    class Relation < ROM::Relation
      def initialize(dataset, registry = {})
        puts '-------------------- PgJson::Relation initialize --------------------'
        super
      end

      def reset_query
        @query = dataset.build_query
        self
      end

      def each(&block)
        return to_enum unless block
        query.each(dataset, &block)
      end

      def limit(amount)
        query.limit(amount)
        self
      end

      def offset(amount)
        query.offset(amount)
        self
      end

      def criteria(spec)
        query.criteria(spec)
        self
      end

      def json_criteria(path, value)
        query.json_criteria(path, value)
        self
      end

      def json_field(name)
        query.json_field(name)
        self
      end

      def query
        @query ||= dataset.build_query
      end
    end
  end
end
