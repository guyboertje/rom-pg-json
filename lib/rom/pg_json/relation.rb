module ROM
  module PgJson
    class Relation < ROM::Relation
      forward :json_field, :json_criteria, :criteria
    end
  end
end
