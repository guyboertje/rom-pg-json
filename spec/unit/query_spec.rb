require 'spec_helper'
require 'rom/pg_json/query'

describe ROM::PgJson::Query do

  let(:query) { described_class.new }

  it 'specify a limit' do
    expected = %{SELECT  "products"."serialised_data" FROM "products" LIMIT 10}
    actual = query.limit(10).sql(:products)
    expect(actual).to eq(expected)
  end

  it 'specify an offset' do
    expected = %{SELECT "products"."serialised_data" FROM "products" OFFSET 10}
    actual = query.offset(10).sql(:products)
    expect(actual).to eq(expected)
  end

  it 'specify where criteria' do
    expected = %{SELECT "products"."serialised_data" FROM "products" WHERE "products"."price" = 2399}
    actual = query.criteria(price: 2399).sql(:products)
    expect(actual).to eq(expected)
  end

  it 'specify where criteria for json field' do
    expected = %{SELECT "products"."serialised_data" FROM "products" WHERE "products"."serialised_data" @> '{"status":"open"}'}
    actual = query.json_criteria('status', 'open').sql(:products)
    expect(actual).to eq(expected)
  end

  it 'specify where expression criteria for json field' do
    expected = %{SELECT "products"."serialised_data" FROM "products" WHERE "products"."serialised_data" -> 'status' ? 'open'}
    actual = query.json_expression_criteria('status', '?', 'open').sql(:products)
    expect(actual).to eq(expected)
  end

  context 'for json data that is not text - integers (e.g. time in seconds since epoch)' do

    it 'specify where expression criteria for path between two integers' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST( "products"."serialised_data" ->> 'expires_i' AS int8 ) BETWEEN 1434927600, 1435014000}
      actual = query.json_expression_time('expires_i', [1434927600, 1435014000]).sql(:products)
      expect(actual).to eq(expected)
    end

    it 'specify where expression criteria for path greater than int' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST( "products"."serialised_data" ->> 'expires_i' AS int8 ) > 1434927600}
      actual = query.json_expression_time('expires_i', [1434927600, '>']).sql(:products)
      expect(actual).to eq(expected)
    end

    it 'specify where expression criteria for path less than int' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST( "products"."serialised_data" ->> 'expires_i' AS int8 ) < 1434927600}
      actual = query.json_expression_time('expires_i', [1434927600, '<']).sql(:products)
      expect(actual).to eq(expected)
    end

    it 'specify where expression criteria for path less than or eq to int' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST( "products"."serialised_data" ->> 'expires_i' AS int8 ) <= 1434927600}
      actual = query.json_expression_time('expires_i', [1434927600, '<=']).sql(:products)
      expect(actual).to eq(expected)
    end

    it 'specify where expression criteria for path greater than or eq to int' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST( "products"."serialised_data" ->> 'expires_i' AS int8 ) >= 1434927600}
      actual = query.json_expression_time('expires_i', [1434927600, '>=']).sql(:products)
      expect(actual).to eq(expected)
    end

    it 'specify where expression criteria for path eq to int' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST( "products"."serialised_data" ->> 'parts_count' AS int8 ) = 2}
      actual = query.json_expression_time('parts_count', [2, '=']).sql(:products)
      expect(actual).to eq(expected)
    end

    it 'specify where expression criteria for path not eq to int' do
      expected = %{SELECT "products"."serialised_data" FROM "products" WHERE CAST( "products"."serialised_data" ->> 'parts_count' AS int8 ) != 1}
      actual = query.json_expression_time('parts_count', [1, '!=']).sql(:products)
      expect(actual).to eq(expected)
    end


  end

end
