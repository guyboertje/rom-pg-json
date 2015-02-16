# rom-pg-json
Add ROM support to create Value objects from Postgres json fields





Example

```ruby
order_model = Class.new do
  include Virtus.value_object

  values do
    attribute :foo, Integer
    attribute :bar, Integer
    attribute :baz, Hash
  end
end

require 'rom_pg_json'

pool = ActiveRecord::Base.establish_connection
Arel::Table.engine = ActiveRecord::Base

set = ROM.setup :pg_json, pool

set.relation(:orders) do
  def byo
    json_criteria('{baz,abc,def,1,ghi}','jtyj')
  end
  def paginate(page, per_page)
    offset(page.pred * per_page).limit(per_page)
  end
end

set.mappers do
  define(:orders) do
    model order_model
  end
end

env = set.finalize

byo = env.read(:orders).byo
some = env.read(:orders).paginate(2, 3)

byo.each{|v| Kernel.ap v}
some.each{|v| Kernel.ap v}
```
