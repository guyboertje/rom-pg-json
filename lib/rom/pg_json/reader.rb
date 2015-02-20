module ROM
  class Reader
    def reset_relation
      old = @relation
      @relation = old.class.new(old.dataset, old.__registry__)
    end
  end

  class Env
    alias_method :orig_read, :read

    def read(name, &block)
      readers[name].reset_relation
      orig_read(name, &block)
    end

    def relate(name, &block)
      old = relations[name]
      relation = old.class.new(old.dataset, old.__registry__)
      
      if block_given?
        yield(relation)
      else
        relation
      end
    end
  end
end
