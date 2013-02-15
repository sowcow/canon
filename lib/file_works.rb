require 'forwardable'
extend Forwardable
require 'fileutils'
def_delegators :FileUtils, :rm_r, :mkpath
def_delegators :File, :join # don't add :read

def rm file_or_dir # or only dir? (test...)
  rm_r file_or_dir if File.exist?(file_or_dir) #|| Dir.exist?(file_or_dir)
end

if __FILE__ == $0
  file = 'temp/123.txt'

  mkpath 'temp'
  File.write file, 123
  rm file
  File.exist? file and raise
  rm 'temp'
  Dir.exist? 'temp' and raise

  puts :OK
end