module ROM
  class Reader
    def initialize(path, relation, mappers, mapper = nil)
      super path, relation.reset_query, mappers, mapper
      puts '-------------------- Reader extension initialize --------------------'
    end
  end
  # module PgJson
  # end
end
