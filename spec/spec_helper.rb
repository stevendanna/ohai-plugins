$:.unshift(File.join(File.dirname(__FILE__), "..", "plguins"))
$:.unshift(File.dirname(__FILE__))
require 'ohai'
Ohai::Config[:plugin_path] = [File.expand_path("plugins/")]

RSpec.configure do |config|
  # Use color in STDOUT
  config.color_enabled = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate
end
