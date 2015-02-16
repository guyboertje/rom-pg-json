module ROM
  class Reader
    def initialize(path, relation, mappers, mapper = nil)
      puts '-------------------- Reader extension initialize --------------------'
      new_relation = relation.reset_query
      puts self.class.ancestors.inspect
      super path, new_relation, mappers, mapper
    end
  end
  # module PgJson
  # end
end
