require 'rom'
require 'rom/pg_json/repository'

ROM.register_adapter(:pg_json, ROM::PgJson)
