require 'rom'
require 'pry-byebug'

root = Pathname(__FILE__).dirname
Dir[root.join('shared/*.rb').to_s].each { |f| require f }
