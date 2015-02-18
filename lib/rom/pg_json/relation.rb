module ROM
  module PgJson
    class Relation < ROM::Relation
      include ROM::PgJson::FluentForwarder.new(:query)

      def initialize(dataset, registry = {})
        super
        @query = dataset.build_query
      end

      def each(&block)
        return to_enum unless block
        dataset.each(query, &block)
      end

      def each_string(&block)
        dataset.each_string(query, &block)
      end

      def all
        dataset.all(query)
      end

      def all_string
        dataset.all_string(query)
      end

      def count
        dataset.count(query)
      end

      def query
        @query
      end
    end
  end
end
