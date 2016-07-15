#\ -p 8000
require './lib/generator'
use Rack::Reloader, 0
use Rack::ContentLength
use Rack::ShowStatus

map "/" do
  use Rack::Static, :urls => ['/index.html'], :root => './public', :index => 'index.html'
  run GeneratorApp.new
end


