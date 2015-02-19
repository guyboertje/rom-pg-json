# rom-pg-json
Add ROM support to create Value objects from Postgres json fields

Why?

You want to keep your investment in Rails and Postgres to
create and update ActiveRecord models - the write side.

You store a denormalised version (NoSql) of a Domain Object
in a json field of the Domain Object's root AR model, e.g. Order.

You realise that you can use this json field on the read side
to speed up your views.

You need a way to query the table with the json field and, to
preserve the speed of the view, you want to bypass AR.

You also realise that you can use this technique for API GETs and
that, with care, you can respond with the json field string
directly - big win, no need for as_json on model instances

Tada! rom-pg-json

In Rails you **can** use the rom-rb/rom-rails gem but it adds
commands i.e. ROM write side.  This gem does not support that.

If you DIY the Rails configuration, I suggest a modified version
of what the rom-rails gem does.
Store your read only models in, say, app/read/models.
Store your relations in, say, app/read/relations
Store your mappers in, say, app/read/mappers

create an initializer with something like
```ruby
require 'rom_pg_json'

read_root = Rails.root.join('app', 'read')

<YourApp>::Application.configure do
  config.eager_load_paths -= [read_root.to_s]
  config.to_prepare do |_|
    if ROM.env
      ROM.setup(ROM.env.repositories)
    else
      ROM.setup(
        :pg_json,
        ActiveRecord::Base.establish_connection,
        ROM::PgJson::Query
      )
    end
    %w(models relations mappers).each do |type|
      Dir[read_root.join("#{type}/**/*.rb").to_s].each do |path|
        require_dependency(path)
      end
    end
    ROM.finalize
  end
end
```

And then in your controller do

@some_relation = ROM.env.read(:some_relation).some_filter

Example

```ruby
OrderModel = Class.new do
  include Virtus.value_object
  values do
    attribute :foo, Integer
    attribute :bar, Integer
    attribute :baz, Hash
  end
end

require 'rom_pg_json'

ROM.setup(
  :pg_json,
  ActiveRecord::Base.establish_connection,
  ROM::PgJson::Query
)

OrdersRelation = Class.new(ROM::Relation[:pg_json]) do
  dataset :orders

  def byo
    json_criteria('{baz,abc,def,1,ghi}','jtyj')
  end

  def paginate(page, per_page)
    offset(page.pred * per_page).limit(per_page)
  end
end

OrdersMapper = Class.new(ROM::Mapper) do
  relation :orders
  model OrderModel
end

ROM.finalize

byo = ROM.env.read(:orders).byo
some = ROM.env.read(:orders).paginate(2, 3)

byo.each{|v| Kernel.ap v}
some.each{|v| Kernel.ap v}

ROM.env.relations[:orders].reset.paginate(2,3).count

```
