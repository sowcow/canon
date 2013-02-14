__END__
require_relative 'output'
require 'yaml'

def load_data file 
  data = YAML.load(File.read)
  puts 'missing tables...' unless
  # .tap { |x| x.delete :tables }
end
# File.write 'build-output.rb', result(YAML.load File.read 'output_all.yml')
data = load_data 'reborn/digha-patterns.yml'

File.write 'digha-output.rb', result()