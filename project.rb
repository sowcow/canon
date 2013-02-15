require_relative 'lib/awesome_marshaling'
require_relative 'lib/selector'
require_relative 'lib/model'
require_relative 'lib/html'
require 'forwardable'
require 'ruby-progressbar'
require 'fileutils'
require 'ostruct'
require 'moneta'
require 'yaml'


class ExtractorProject; is Model :directory
  include Forwardable
  include CollectionFile
  include HTML
  CONFIG = 'config.yml'
  FORMAT = YAML

  @DEFAULT_CONFIG = {} # split between mixins
  singleton_class.send :attr_reader, :DEFAULT_CONFIG


  # central method
  def process
    raise 'we need some source htmls first' unless exist? source_file
    extract_text_nodes unless exist? text_nodes_file
  end


  module SourceFile # to find better sequental storage?
    def source
      Load source_file
    end

    def add_source *htmls
      [*htmls].each do |html|
        # Save source_file do |file| file << html end
        Push source_file, html
      end
    end
    alias add_sources add_source

    def self.included target; target.instance_eval do 
      @DEFAULT_CONFIG.merge! 'source' => 'source.bin'
    end; end
  end
  include SourceFile

  def selector node
    Selector[node].to_a
  end


  module TextNodesFile # hash of sequental access array ...
    def extract_text_nodes
      file = text_nodes

      htmls = source
      progress = progress_bar htmls.count
      htmls.each do |html|
        texts(html).each do |node|
          selector = selector(node)

          file[selector] = [] unless file.key? selector
          file[selector] = file[selector] << node.text
        end
        progress.increment
      end
      file.close
    end
    def text_nodes
      Moneta.new :LevelDB, dir: text_nodes_file
    end
    def self.included target; target.instance_eval do
      @DEFAULT_CONFIG.merge! 'text_nodes' => 'text_nodes'
    end; end
  end
  include TextNodesFile


  def initialize(*);super
    unless exist? config_file # initialize project
      mkpath directory
      save config_file, default_config
    end
  end

  def default_config
    self.class.DEFAULT_CONFIG
  end

  def source
    return nil unless exist? source_file
    @source ||= super
  end

  def text_nodes
    return nil unless exist? text_nodes_file
    super # @source ||= super
  end  

  def reload!
    @config = nil
    @source = nil
  end

  def config
    @config ||= OpenStruct.new load config_file
  end

  private
  def config_file; the CONFIG end
  def source_file; the config[:source] end
  def text_nodes_file; the config[:text_nodes] end

  def the file; join directory, file end
  def save file, data; write file, FORMAT.dump(data) end
  def load file; FORMAT.load read file end

  extend Forwardable
  def_delegators :File, :join, :exist?, :write, :read # read can cause problems?
  def_delegators :FileUtils, :mkpath

  def progress_bar total
    ProgressBar.create format: '%a %e [%B] %p%%', total: total
  end
end


if __FILE__ == $0
  require_relative 'lib/file_works'
  rm 'temp'

  project = ExtractorProject['temp/projets/this']
  project.config.to_h.keys == %i[source text_nodes] or raise
  (project.process rescue :fail) == :fail or raise
  project.add_source '<ul><li>1</li><li>2</li><li>3</li></ul><span>other</span>'
  project.add_source '<ul><li>4</li></ul>'
  project.process

  data =  project.text_nodes.adapter.backend.to_a.map { |x| x.map{|y| Marshal.load y} }
  data[0] == [["document", "html", "body", "span", "text"], ["other"]] or raise
  data[1] == [["document", "html", "body", "ul", "li", "text"], ["1", "2", "3", "4"]] or raise

  puts :OK
end