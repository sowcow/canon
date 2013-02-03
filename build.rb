require_relative 'output'
require 'yaml'

File.write 'build-output.rb', result(YAML.load File.read 'output_all.yml')
