module ROM
  class Reader
    def reset_relation
      relation.reset_query
    end
  end

  class Env
    alias_method :orig_read, :read

    def read(name, &block)
      readers[name].reset_relation
      orig_read(name, &block)
    end
  end
end
