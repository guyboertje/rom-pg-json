require 'rom'
require 'rom/pg_json/repository'
require 'rom/pg_json/dataset'
require 'rom/pg_json/relation'

ROM.register_adapter(:pg_json, ROM::PgJson)
