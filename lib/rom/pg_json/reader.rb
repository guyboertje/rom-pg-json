module ROM
  module PgJson
    module Reader
      def initialize(path, relation, mappers, mapper = nil)
        super
        @relation = relation.reset_query
        puts '-------------------- Reader extension initialize --------------------'
      end
    end
  end
end
