$:.unshift(File.join(File.dirname(__FILE__), "..", "plguins"))
$:.unshift(File.dirname(__FILE__))
require 'ohai'
Ohai::Config[:plugin_path] = [File.expand_path("plugins/")]
