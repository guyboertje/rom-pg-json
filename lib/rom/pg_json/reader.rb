module ROM
  class Reader
    def reset_relation
      original_relation = @relation
      @relation = original_relation.class.new(original_relation.dataset, original_relation.__registry__)
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
