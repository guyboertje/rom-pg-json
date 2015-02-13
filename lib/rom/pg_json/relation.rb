module ROM
  module PgJson
    class Relation < ROM::Relation
      def initialize(dataset, registry = {})
        puts '-------------------- PgJson::Relation initialize --------------------'
        super
      end

      forward :json_field, :json_criteria, :criteria, :limit, :offset, :exec, :reset
    end
  end
end
