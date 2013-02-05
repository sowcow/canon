this = Module.new do
  extend self
  
  def file
    File.expand_path __FILE__
  end
  
  def dir
    File.split(file)[0]
  end    
end

def ruby_files_at dir
  Dir["#{dir}/*.rb"].to_a
end

def require_here dir
  ruby_files_at(dir).each { |file| require_relative file }
end


require_here this.dir