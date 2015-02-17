require 'rom'
require 'rom/pg_json/fluent_forwarder'
require 'rom/pg_json/reader'
require 'rom/pg_json/repository'
require 'rom/pg_json/query'
require 'rom/pg_json/dataset'
require 'rom/pg_json/relation'

ROM.register_adapter(:pg_json, ROM::PgJson)
