require File.expand_path '../lib/public.rb', __FILE__
require File.expand_path '../lib/api.rb', __FILE__

run Rack::URLMap.new({
  '/' => Public,
  '/api' => Api
})
