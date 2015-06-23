require 'spec_helper'
require 'rom/pg_json/dataset'
require 'rom/pg_json/query'

describe ROM::PgJson::Dataset do
  let(:pool)    { FakeRecord::Base.new.connection_pool }
  let(:query)   { ROM::PgJson::Query.new }
  let(:dataset) { described_class.new(:products, pool, ROM::PgJson::Query) }

  it 'returns all records as hashes for a given query' do
    expected = [{"id"=>1, "name"=>"foo", "price"=>4200, "expired"=>true}, {"id"=>2, "name"=>"bar", "price"=>4250, "expired"=>false}, {"id"=>3, "name"=>"baz", "price"=>4400, "expired"=>false}]
    actual = dataset.all(query)
    expect(expected).to eq(actual)
  end

  it 'returns each record as a hash for a given query and block' do
    expected = [{"id"=>1, "name"=>"foo", "price"=>4200, "expired"=>true}, {"id"=>2, "name"=>"bar", "price"=>4250, "expired"=>false}, {"id"=>3, "name"=>"baz", "price"=>4400, "expired"=>false}]
    actual = []
    dataset.each(query) {|rec| actual.push rec}
    expect(expected).to eq(actual)
  end

  it 'returns all records as strings for a given query' do
    expected = ["{\"id\":1,\"name\":\"foo\",\"price\":4200,\"expired\":true}", "{\"id\":2,\"name\":\"bar\",\"price\":4250,\"expired\":false}", "{\"id\":3,\"name\":\"baz\",\"price\":4400,\"expired\":false}"]
    actual = dataset.all_string(query)
    expect(expected).to eq(actual)
  end

  it 'returns all records as strings for a given query and block' do
    expected = ["{\"id\":1,\"name\":\"foo\",\"price\":4200,\"expired\":true}", "{\"id\":2,\"name\":\"bar\",\"price\":4250,\"expired\":false}", "{\"id\":3,\"name\":\"baz\",\"price\":4400,\"expired\":false}"]
    actual = []
    dataset.each_string(query){|str| actual.push str}
    expect(expected).to eq(actual)
  end

  it 'returns the count of results returned by the query' do
    actual = dataset.count(query)
    expect(actual).to eq(20)
  end
end
