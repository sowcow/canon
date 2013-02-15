require_relative 'project'
require_relative 'canon'

project = ExtractorProject['output/majjhima']
WTP.get.only!(MAJJHIMA).htmls.each { |html| project.add_source html } unless project.source
project.source.count == 203 or raise 'wtf! sholud be 203 files in Majjhima'
project.process