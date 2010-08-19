require 'shinmun'

use Rack::Session::Cookie
use Rack::Reloader

blog = Shinmun::Blog.new(File.dirname(__FILE__))

blog.config = {
  :language => 'en',
  :title => "{{ ty's engineering log }}",
  :author => "Ng Tze Yang",
  :categories => %w{misc ruby},
  :description => "non-optimized bits & pieces of my techincal side"
}

run blog
