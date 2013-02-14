require 'forwardable'
extend Forwardable
require 'fileutils'
def_delegators :FileUtils, :rm_r, :mkpath

def rm file_or_dir # or only dir? (test...)
  rm_r file_or_dir if File.exist?(file_or_dir) #|| Dir.exist?(file_or_dir)
end