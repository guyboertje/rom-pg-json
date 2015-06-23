require 'spec_helper'
require 'rom/pg_json/query'

describe ROM::PgJson::Query do

  let(:query) { described_class.new }

  it 'generates sql' do
    expected = %{SELECT "products"."serialised_data" FROM "products" ORDER BY "products"."id" ASC}
    actual = query.sql(:products)
    expect(expected).to eq(actual.squeeze(' '))
  end

  it 'specify a limit' do
    expected = %{SELECT "products"."serialised_data" FROM "products" ORDER BY "products"."id" ASC LIMIT 10}
    actual = query.limit(10).sql(:products)
    expect(expected).to eq(actual.squeeze(' '))
  end

  it 'specify an offset' do
    expected = %{SELECT "products"."serialised_data" FROM "products" ORDER BY "products"."id" ASC OFFSET 10}
    actual = query.offset(10).sql(:products)
    expect(expected).to eq(actual.squeeze(' '))
  end

  it 'specify where criteria' do
    expected = %{SELECT "products"."serialised_data" FROM "products" WHERE "products"."price" = 2399 ORDER BY "products"."id" ASC}
    actual = query.criteria(price: 2399).sql(:products)
    expect(expected).to eq(actual.squeeze(' '))
  end

  it 'specify where criteria for json field' do
    expected = %{SELECT "products"."serialised_data" FROM "products" WHERE "products"."serialised_data" @> '{"status":"open"}' ORDER BY "products"."id" ASC}
    actual = query.json_criteria('status', 'open').sql(:products)
    expect(expected).to eq(actual.squeeze(' '))
  end

  it 'specify where expression criteria for json field' do
    expected = %{SELECT "products"."serialised_data" FROM "products" WHERE "products"."serialised_data" -> 'status' ? 'open' ORDER BY "products"."id" ASC}
    actual = query.json_expression_criteria('status', '?', 'open').sql(:products)
    expect(expected).to eq(actual.squeeze(' '))
  end

  context 'for json data that is not text - integers (e.g. time in seconds since epoch)' do

    it 'specify where expression criteria for path between two integers' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST("products"."serialised_data" ->> 'expires_i' AS int8) BETWEEN 1434927600 AND 1435014000 ORDER BY "products"."id" ASC}
      actual = query.json_expression_time('expires_i', [1434927600, 1435014000]).sql(:products)
      expect(expected).to eq(actual.squeeze(' '))
    end

    it 'specify where expression criteria for path greater than int' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST("products"."serialised_data" ->> 'expires_i' AS int8) > 1434927600 ORDER BY "products"."id" ASC}
      actual = query.json_expression_time('expires_i', [1434927600, '>']).sql(:products)
      expect(expected).to eq(actual.squeeze(' '))
    end

    it 'specify where expression criteria for path less than int' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST("products"."serialised_data" ->> 'expires_i' AS int8) < 1434927600 ORDER BY "products"."id" ASC}
      actual = query.json_expression_time('expires_i', [1434927600, '<']).sql(:products)
      expect(expected).to eq(actual.squeeze(' '))
    end

    it 'specify where expression criteria for path less than or eq to int' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST("products"."serialised_data" ->> 'expires_i' AS int8) <= 1434927600 ORDER BY "products"."id" ASC}
      actual = query.json_expression_time('expires_i', [1434927600, '<=']).sql(:products)
      expect(expected).to eq(actual.squeeze(' '))
    end

    it 'specify where expression criteria for path greater than or eq to int' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST("products"."serialised_data" ->> 'expires_i' AS int8) >= 1434927600 ORDER BY "products"."id" ASC}
      actual = query.json_expression_time('expires_i', [1434927600, '>=']).sql(:products)
      expect(expected).to eq(actual.squeeze(' '))
    end

    it 'specify where expression criteria for path eq to int' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST("products"."serialised_data" ->> 'parts_count' AS int8) = 2 ORDER BY "products"."id" ASC}
      actual = query.json_expression_time('parts_count', [2, '=']).sql(:products)
      expect(expected).to eq(actual.squeeze(' '))
    end

    it 'specify where expression criteria for path not eq to int' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST("products"."serialised_data" ->> 'parts_count' AS int8) != 1 ORDER BY "products"."id" ASC}
      actual = query.json_expression_time('parts_count', [1, '!=']).sql(:products)
      expect(expected).to eq(actual.squeeze(' '))
    end
  end

  it 'specify where json ordering for path' do
    expected = %{SELECT "products"."serialised_data" FROM "products" ORDER BY "products"."serialised_data" -> 'parts_count' DESC}
    actual = query.json_order_by({'parts_count' => 'desc'}).sql(:products)
    expect(expected).to eq(actual.squeeze(' '))
  end

  it 'specify a different json field' do
    expected = %{SELECT "products"."jdata" FROM "products" ORDER BY "products"."jdata" -> 'parts_count' DESC}
    actual = query.json_field(:jdata).json_order_by({'parts_count' => 'desc'}).sql(:products)
    expect(expected).to eq(actual.squeeze(' '))
  end

  it 'specify regular ordering' do
    expected = %{SELECT "products"."jdata" FROM "products" ORDER BY "products"."price" DESC}
    actual = query.json_field(:jdata).order_by({'price' => 'desc'}).sql(:products)
    expect(expected).to eq(actual.squeeze(' '))
  end

  it 'generates count sql' do
    expected = %{SELECT COUNT(count_column) FROM (SELECT 1 AS count_column FROM "products" WHERE "products"."serialised_data" @> '{"status":"open"}') subquery_for_count}
    actual = query.json_criteria('status', 'open').count_sql(:products)
    expect(expected).to eq(actual.squeeze(' '))
  end

end
