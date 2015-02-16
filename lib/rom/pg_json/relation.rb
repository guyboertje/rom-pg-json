module ROM
  module PgJson
    class Relation < ROM::Relation
      include Enumerable

      def each(&block)
        return to_enum unless block
        dataset.each(query, &block)
      end

      def all
        dataset.all(query)
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
