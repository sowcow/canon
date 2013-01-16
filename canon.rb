#============================
#
#  wtp -< parts -< pages
#           |        |
#           name     html
#
#============================
#
# WTP.get ~ load canon file
#
#============================

class Page < Struct.new :html
end

class Part < Struct.new :name, :pages
end

class WTP < Struct.new :parts
  def self.get
    marshal_load 'canon'
  end

  def only! selector
    parts.select! { |x| selector.include? x.name }
    self
  end

  extend FileWorks
end

module Selectors
  DIGHA = %w[6D 7D 8D]
  MAJJHIMA = %w[9M 10M 11M]
  SAMYUTTA = %w[12S1 12S2 13S3 13S4 14S5]
  ANGUTTARA = %w[15A1 15A2 15A3 15A4 16A5 16A6 16A7 17A8 17A9 17A10 17A11]
  FOUR_NIKAYAS = DIGHA + ANGUTTARA + MAJJHIMA + SAMYUTTA
end
include Selectors


if __FILE__ == $0
  raise unless WTP.get.only!(FOUR_NIKAYAS).parts.count == 22

  wtp = WTP.get
  raise unless wtp.parts.count == 88
  raise unless wtp.parts.map(&:name).include? '1V' # Vinaya 1 volume 
                                                   # btw this devison into volumes was for printing purposes...
                                                   # http://archive.is/Ugwv

  raise unless wtp.parts.sample.pages.sample.html =~ /doctype/i # random page

  all_pages = wtp.parts.map { |x|x.pages.map &:html }.flatten
  raise unless all_pages.count == 20108
  raise unless all_pages.all? { |x|x =~ /doctype/i }

  puts 'OK'
end



BEGIN{
  module FileWorks
    module_function

    def marshal_load file
      Marshal.load File.read file
    end
  end
}