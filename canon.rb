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

require 'zlib' # canon is compressed (500-23 Mb)
# so beware of exit code -9 or `failed to allocate memory`

class WTP < Struct.new :parts

  class Part < Struct.new :name, :pages
  end
  class Page < Struct.new :html
  end

  def self.get
    marshal_load_archived 'canon.bin'
  end

  def self.pages count=nil
    count ? all_pages.sample(count) : all_pages
  end

  def self.all_pages # redundant?
    get.all_pages
  end  

  def all_pages
    parts.map { |part| part.pages.map { |page| {html: page.html, part: part.name} }}.flatten
  end

  def htmls
    all_pages.map { |x| x[:html] }
  end

  def only! selector
    parts.select! { |x| [*selector].include? x.name }
    self
  end

  module Selectors
    VINAYA = %w[1V 2V 3V 4V 5V]
    DIGHA = %w[6D 7D 8D]
    MAJJHIMA = %w[9M 10M 11M]
    SAMYUTTA = %w[12S1 12S2 13S3 13S4 14S5]
    ANGUTTARA = %w[15A1 15A2 15A3 15A4 16A5 16A6 16A7 17A8 17A9 17A10 17A11]
    FOUR_NIKAYAS = DIGHA + ANGUTTARA + MAJJHIMA + SAMYUTTA
    ALL = %w[8D 36P1 22J 40P10 14S5 15A2 40P8 23J 40P11 15A3 1V 18Sn 17A9 13S4 33Y5 17A10 2V 34Y6 17A11 34Y7 3V 18Kh 34Y8 4V 18Dh 35Y9 5V 18Ud 35Y10 6D 18It 24Mn 39P3 38P2 9M 10M 37P1 7D 19Vv 19Pv 11M 19Th1 39P4 12S1 19Th2 39P5 12S2 20Ap1 39P6 13S3 20Ap2 40P7 21Bu 21Cp 40P9 15A1 40P12 15A4 25Cn 40P13 16A5 26Ps 40P14 16A6 27Ne 40P15 16A7 27Pe 40P16 17A8 28Mi 40P17 29Dhs 40P18 30Vbh 40P19 31Dht 40P20 31Pu 40P21 32Kv 40P22 33Y1 40P23 33Y2 40P24 33Y3 33Y4]
  end

  extend FileWorks
end

include WTP::Selectors


if __FILE__ == $0
  raise unless WTP.get.only!(FOUR_NIKAYAS).parts.count == 22

  wtp = WTP.get
  raise unless wtp.parts.count == 88
  raise unless wtp.parts.map(&:name).include? '1V' # Vinaya 1 volume 
                                                   # btw this devison into volumes was for printing purposes...
                                                   # http://archive.is/Ugwv

  raise unless wtp.parts.sample.pages.sample.html =~ /doctype/i # random page

  raise unless ALL.uniq.count == 88

require 'testdo'
test do
  WTP.pages.count === 20108
  WTP.pages(10).count === 10
  wtp.htmls.sample(10).all? { |x| x =~ /doctype/i }
  WTP.pages(10).all? { |x| x[:html] =~ /doctype/i }
  WTP.pages(10).all? { |x| x[:part] =~ /^\d/ }
end
end



BEGIN{
  module FileWorks
    module_function

    # require 'zlib' # jruby crap anyway: marshal data too short:)
    # INFLATER = ::Zlib::Inflate.new #(-Zlib::MAX_WBITS)
    def marshal_load_archived file
      Marshal.load Zlib.inflate File.read file 
    end
  end
}
__END__
# compressing canon:
# irb > require'zlib'; canon = File.read('canon'); File.write('canon.bin',Zlib.deflate(canon))
# recreating canon:
# irb > require'./canon'; canon = WTP.get; def recreate obj; case obj; when WTP then WTP[obj.parts.map{|x|recreate x}]; when Part then WTP::Part[obj.name,obj.pages.map{|x|recreate x}]; when Page then WTP::Page[obj.html]; end end; File.write 'recanon.bin', Zlib.deflate(Marshal.dump recreate(canon))