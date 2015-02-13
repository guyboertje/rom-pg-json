module ROM
  class Reader
    def initialize(path, relation, mappers, mapper = nil)
      super
      @relation = relation.reset_query
      puts '-------------------- Reader extension initialize --------------------'
    end
  end
  # module PgJson
  # end
end
