require 'rubygems'
require 'bundler/setup'

require 'rom'

require 'arel'
require 'arel_pg_json'
require 'pry-byebug'
require 'oj'

root = Pathname(__FILE__).dirname
Dir[root.join('support/*.rb').to_s].each { |f| require f }

Arel::Table.engine = FakeRecord::Base.new
Oj.default_options = { mode: :strict }

module HashToJson
  def to_json
    JSON.dump(self)
  end
end

Hash.send :include, HashToJson
