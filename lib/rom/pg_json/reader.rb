module ROM
  class Reader
    def reset_relation
      relation.reset_query
    end
  end

  class Env
    def read(name, &block)
      readers[name].reset_relation
      super
    end
  end
end
