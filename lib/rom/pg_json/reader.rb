module ROM
  class Reader
    def initialize(path, relation, mappers, mapper = nil)
      puts '-------------------- Reader extension initialize --------------------'
      puts self.class.superclass.instance_method(:initialize).inspect
      super path, relation.reset_query, mappers, mapper
    end
  end
  # module PgJson
  # end
end
