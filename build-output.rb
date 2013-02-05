#encoding: utf-8
require 'nokogiri'
require 'forwardable'
require File.expand_path './lib/selector'
require 'set'

#require_relative 'selector'
#require_relative 'lib/selector'

END{
  require_relative 'canon'
  if broken_page = WTP.pages.find { |x| not Output::Page.new(x).valid? } 
    elements = Output::Page.new(broken_page).elements.select { |x| not x.valid? }
    p elements.count
    elements.each do |e|
      p e
    end
  end
}

#<Output::Page::Elements::Element_3:0x00000025c1cdf0 @node=
#<Nokogiri::XML::Element:0x12d7c8e8 name="link" 
#attributes=[#<Nokogiri::XML::Attr:0x1a946dc name="rel" value="next">, 
#<Nokogiri::XML::Attr:0x1a946b4 name="href" value="/tipitaka/3V/1">]>>

module Helpers
  def split html
    [].tap do |nodes|
      Nokogiri::HTML(html).at('html').traverse { |node| nodes << node }
    end
  end
  # def subclasses
  #   ObjectSpace.each_object(Class).select { |klass| klass < self.class }
  # end
  def key node
    Selector[node].to_s
  end
end

module Output
class Page
  include Helpers
  attr_reader :elements

  def initialize page_html=nil
    @elements = split(page_html).map { |node| find_element_for node } if page_html
  end
  def valid?
    elements.all? &:valid?
  end

  # private
  def find_element_for node
    found = find_elements(key(node))
    raise "wtf? #{found}" unless found.count == 1
    found = found[0]
    found.new(node)
  end
  def find_elements key
    element_classes.select { |x| x.accept? key }
  end
  def element_classes
    Elements.constants.reject { |x| x == :Base }.map { |x| Elements.const_get(x) }.select { |x| x.is_a? Class }
  end

  module Elements
    
    class Base
      def initialize node; @node = node end
      def self.accept? key
        self::MATCH =~ key ? true: false
      end

      def method_missing *a; node.send *a end
      #extend Forwardable
      #def_delegators :@node, :children, :attr
      private; attr_reader :node


      ### extractor.rb monkey patching ###
      def children_tags
        children.map &:name
      end
      def children_classes
        children.map &x{ self[:class] }
      end
      def children_ids
        children.map &x{ self[:id] }
      end
    end

    class Element_0 < Base
      MATCH = /^document\ >\ html\ >\ head\ >\ title\ >\ text$/

      def valid? # Rules count: 9
        (25..92) === to_html.size &&
        /^.*\ \|\ Tipiṭaka\ Quotation$/m === to_html &&
        (25..92) === text.to_s.size &&
        /^.*\ \|\ Tipiṭaka\ Quotation$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        true
      end
    end
    class Element_1 < Base
      MATCH = /^document\ >\ html\ >\ head\ >\ title$/

      def valid? # Rules count: 9
        (41..108) === to_html.size &&
        /^<title>.*\ \|\ Tipi\u1E6Daka\ Quotation<\/title>\n$/m === to_html &&
        (25..92) === text.to_s.size &&
        /^.*\ \|\ Tipiṭaka\ Quotation$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        
        true
      end
    end
    class Element_2 < Base
      MATCH = /^document\ >\ html\ >\ head\ >\ meta$/

      def valid? # Rules count: 9
        68 === to_html.size &&
        "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "Content-Type" === node['http-equiv'] &&
"text/html; charset=utf-8" === node['content'] &&
        true
      end
    end
    class Element_3 < Base
      MATCH = /^document\ >\ html\ >\ head\ >\ link$/

      def valid? # Rules count: 9
        (36..103) === to_html.size &&
        /^<link\ rel=".*">\n$/m === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        Set["next", "shortcut icon", "prev", "up"].include?(node['rel']) &&
/^\/.*$/m === node['href'] &&
"image/x-icon" === node['type'] &&
        true
      end
    end
    class Element_4 < Base
      MATCH = /^document\ >\ html\ >\ head\ >\ style\ >\ \#cdata\-section$/

      def valid? # Rules count: 9
        (33..67) === to_html.size &&
        /^@import\ "\/.*\.css";$/m === to_html &&
        (33..67) === text.to_s.size &&
        /^@import\ "\/.*\.css";$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_5 < Base
      MATCH = /^document\ >\ html\ >\ head\ >\ style$/

      def valid? # Rules count: 9
        (77..111) === to_html.size &&
        /^<style\ type="text\/css"\ media="all">@import\ "\/.*\.css";<\/style>\n$/m === to_html &&
        (33..67) === text.to_s.size &&
        /^@import\ "\/.*\.css";$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["#cdata-section"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "text/css" === node['type'] &&
"all" === node['media'] &&
        true
      end
    end
    class Element_6 < Base
      MATCH = /^document\ >\ html\ >\ head\ >\ script$/

      def valid? # Rules count: 9
        (41..264) === to_html.size &&
        /^<script\ type="text\/javascript".*<\/script>$/m === to_html &&
        Set[0, 224, 19, 1].include?(text.to_s.size) &&
        Set["", "Drupal.extend({ settings: { \"iautocomplete\": { \"targetSearchBox\": \"theme\", \"limitNum\": 100, \"limitShow\": 20, \"delayDuration\": 1250, \"queryURL\": \"/iautocomplete/tipitaka\", \"minimumWordSize\": \"1\", \"searchAllowed\": true } } });", "var BASE_URL = \"/\";", " "].include?(text.to_s) &&
        Set[0, 1].include?(children.count) &&
        Set[[], ["#cdata-section"]].include?(children_tags) &&
        Set[[], [nil]].include?(children_classes) &&
        Set[[], [nil]].include?(children_ids) &&
        "text/javascript" === node['type'] &&
Set["/misc/jquery.js", "/misc/drupal.js", "/sites/all/modules/tipitaka/tipitaka.js", "/sites/all/modules/tipitaka/colorpicker.js", "/sites/all/modules/iAutocomplete/jquery.dimensions.js", "/sites/all/modules/iAutocomplete/jquery.bgiframe.min.js", "/sites/all/modules/iAutocomplete/iautocomplete.js", "/sites/all/modules/img_assist/img_assist.js", "/sites/all/modules/tipitaka/tipitaka_special_char.js"].include?(node['src']) &&
        true
      end
    end
    class Element_7 < Base
      MATCH = /^document\ >\ html\ >\ head\ >\ script\ >\ \#cdata\-section$/

      def valid? # Rules count: 9
        Set[224, 19, 1].include?(to_html.size) &&
        Set["Drupal.extend({ settings: { \"iautocomplete\": { \"targetSearchBox\": \"theme\", \"limitNum\": 100, \"limitShow\": 20, \"delayDuration\": 1250, \"queryURL\": \"/iautocomplete/tipitaka\", \"minimumWordSize\": \"1\", \"searchAllowed\": true } } });", "var BASE_URL = \"/\";", " "].include?(to_html) &&
        Set[224, 19, 1].include?(text.to_s.size) &&
        Set["Drupal.extend({ settings: { \"iautocomplete\": { \"targetSearchBox\": \"theme\", \"limitNum\": 100, \"limitShow\": 20, \"delayDuration\": 1250, \"queryURL\": \"/iautocomplete/tipitaka\", \"minimumWordSize\": \"1\", \"searchAllowed\": true } } });", "var BASE_URL = \"/\";", " "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_8 < Base
      MATCH = /^document\ >\ html\ >\ head$/

      def valid? # Rules count: 9
        (2586..2818) === to_html.size &&
        /^<head>\n<title>.*">\n<link\ rel="shortcut\ icon"\ href="\/files\/founder3_favicon\.png"\ type="image\/x\-icon">\n<style\ type="text\/css"\ media="all">@import\ "\/modules\/node\/node\.css";<\/style>\n<style\ type="text\/css"\ media="all">@import\ "\/modules\/system\/defaults\.css";<\/style>\n<style\ type="text\/css"\ media="all">@import\ "\/modules\/system\/system\.css";<\/style>\n<style\ type="text\/css"\ media="all">@import\ "\/modules\/user\/user\.css";<\/style>\n<style\ type="text\/css"\ media="all">@import\ "\/sites\/all\/modules\/cck\/content\.css";<\/style>\n<style\ type="text\/css"\ media="all">@import\ "\/sites\/all\/modules\/iAutocomplete\/iautocomplete\.css";<\/style>\n<style\ type="text\/css"\ media="all">@import\ "\/modules\/search\/search\.css";<\/style>\n<style\ type="text\/css"\ media="all">@import\ "\/sites\/all\/modules\/img_assist\/img_assist\.css";<\/style>\n<style\ type="text\/css"\ media="all">@import\ "\/sites\/all\/modules\/tagadelic\/tagadelic\.css";<\/style>\n<style\ type="text\/css"\ media="all">@import\ "\/sites\/all\/modules\/tipitaka\/tipitaka\.css";<\/style>\n<style\ type="text\/css"\ media="all">@import\ "\/sites\/all\/modules\/tipitaka_pageref\/tipitaka_pageref\.css";<\/style>\n<style\ type="text\/css"\ media="all">@import\ "\/sites\/all\/modules\/cck\/fieldgroup\.css";<\/style>\n<style\ type="text\/css"\ media="all">@import\ "\/sites\/all\/themes\/founder3\/style\.css";<\/style>\n<script\ type="text\/javascript"\ src="\/misc\/jquery\.js"><\/script><script\ type="text\/javascript"\ src="\/misc\/drupal\.js"><\/script><script\ type="text\/javascript"\ src="\/sites\/all\/modules\/tipitaka\/tipitaka\.js"><\/script><script\ type="text\/javascript"\ src="\/sites\/all\/modules\/tipitaka\/colorpicker\.js"><\/script><script\ type="text\/javascript"\ src="\/sites\/all\/modules\/iAutocomplete\/jquery\.dimensions\.js"><\/script><script\ type="text\/javascript"\ src="\/sites\/all\/modules\/iAutocomplete\/jquery\.bgiframe\.min\.js"><\/script><script\ type="text\/javascript"\ src="\/sites\/all\/modules\/iAutocomplete\/iautocomplete\.js"><\/script><script\ type="text\/javascript"\ src="\/sites\/all\/modules\/img_assist\/img_assist\.js"><\/script><script\ type="text\/javascript"\ src="\/sites\/all\/modules\/tipitaka\/tipitaka_special_char\.js"><\/script><script\ type="text\/javascript">Drupal\.extend\(\{\ settings:\ \{\ "iautocomplete":\ \{\ "targetSearchBox":\ "theme",\ "limitNum":\ 100,\ "limitShow":\ 20,\ "delayDuration":\ 1250,\ "queryURL":\ "\/iautocomplete\/tipitaka",\ "minimumWordSize":\ "1",\ "searchAllowed":\ true\ \}\ \}\ \}\);<\/script><script\ type="text\/javascript">var\ BASE_URL\ =\ "\/";<\/script><script\ type="text\/javascript">\ <\/script>\n<\/head>\n$/m === to_html &&
        (875..942) === text.to_s.size &&
        /^.*\ \|\ Tipi\u1E6Daka\ Quotation@import\ "\/modules\/node\/node\.css";@import\ "\/modules\/system\/defaults\.css";@import\ "\/modules\/system\/system\.css";@import\ "\/modules\/user\/user\.css";@import\ "\/sites\/all\/modules\/cck\/content\.css";@import\ "\/sites\/all\/modules\/iAutocomplete\/iautocomplete\.css";@import\ "\/modules\/search\/search\.css";@import\ "\/sites\/all\/modules\/img_assist\/img_assist\.css";@import\ "\/sites\/all\/modules\/tagadelic\/tagadelic\.css";@import\ "\/sites\/all\/modules\/tipitaka\/tipitaka\.css";@import\ "\/sites\/all\/modules\/tipitaka_pageref\/tipitaka_pageref\.css";@import\ "\/sites\/all\/modules\/cck\/fieldgroup\.css";@import\ "\/sites\/all\/themes\/founder3\/style\.css";Drupal\.extend\(\{\ settings:\ \{\ "iautocomplete":\ \{\ "targetSearchBox":\ "theme",\ "limitNum":\ 100,\ "limitShow":\ 20,\ "delayDuration":\ 1250,\ "queryURL":\ "\/iautocomplete\/tipitaka",\ "minimumWordSize":\ "1",\ "searchAllowed":\ true\ \}\ \}\ \}\);var\ BASE_URL\ =\ "\/";\ $/m === text.to_s &&
        Set[29, 31, 30].include?(children.count) &&
        Set[["title", "meta", "link", "link", "style", "style", "style", "style", "style", "style", "style", "style", "style", "style", "style", "style", "style", "script", "script", "script", "script", "script", "script", "script", "script", "script", "script", "script", "script"], ["title", "meta", "link", "link", "link", "link", "style", "style", "style", "style", "style", "style", "style", "style", "style", "style", "style", "style", "style", "script", "script", "script", "script", "script", "script", "script", "script", "script", "script", "script", "script"], ["title", "meta", "link", "link", "link", "style", "style", "style", "style", "style", "style", "style", "style", "style", "style", "style", "style", "style", "script", "script", "script", "script", "script", "script", "script", "script", "script", "script", "script", "script"]].include?(children_tags) &&
        Set[[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]].include?(children_classes) &&
        Set[[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]].include?(children_ids) &&
        
        true
      end
    end
    class Element_9 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ text$/

      def valid? # Rules count: 9
        Set[2, 1].include?(to_html.size) &&
        Set["\n\n", "\n"].include?(to_html) &&
        Set[2, 1].include?(text.to_s.size) &&
        Set["\n\n", "\n"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_10 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#logo\ >\ text$/

      def valid? # Rules count: 9
        Set[7, 11].include?(to_html.size) &&
        Set["\n      ", "      \n    "].include?(to_html) &&
        Set[7, 11].include?(text.to_s.size) &&
        Set["\n      ", "      \n    "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_11 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#logo\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        47 === to_html.size &&
        "<img src=\"/files/founder3_logo.gif\" alt=\"Home\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/files/founder3_logo.gif" === node['src'] &&
"Home" === node['alt'] &&
        true
      end
    end
    class Element_12 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#logo\ >\ a$/

      def valid? # Rules count: 9
        76 === to_html.size &&
        "<a href=\"/\" title=\"Home\"><img src=\"/files/founder3_logo.gif\" alt=\"Home\"></a>" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        1 === children.count &&
        (children_tags - ["img"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "/" === node['href'] &&
"Home" === node['title'] &&
        true
      end
    end
    class Element_13 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#logo$/

      def valid? # Rules count: 9
        113 === to_html.size &&
        "<td id=\"logo\">\n      <a href=\"/\" title=\"Home\"><img src=\"/files/founder3_logo.gif\" alt=\"Home\"></a>      \n    </td>" === to_html &&
        18 === text.to_s.size &&
        "\n            \n    " === text.to_s &&
        3 === children.count &&
        (children_tags - ["text", "a", "text"] == []) &&
        (children_classes - [nil, nil, nil] == []) &&
        (children_ids - [nil, nil, nil] == []) &&
        "logo" === node['id'] &&
        true
      end
    end
    class Element_14 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ text$/

      def valid? # Rules count: 9
        Set[5, 3].include?(to_html.size) &&
        Set["\n    ", "\n  "].include?(to_html) &&
        Set[5, 3].include?(text.to_s.size) &&
        Set["\n    ", "\n  "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_15 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu\ >\ text$/

      def valid? # Rules count: 9
        Set[13, 4].include?(to_html.size) &&
        Set["\n            ", "    "].include?(to_html) &&
        Set[13, 4].include?(text.to_s.size) &&
        Set["\n            ", "    "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_16 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu\ >\ div\#search\-theme\-form\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_17 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu\ >\ div\#search\-theme\-form\ >\ div\ >\ div\#search\.container\-inline\ >\ div\#edit\-search\-theme\-form\-keys\-wrapper\.form\-item\ >\ text$/

      def valid? # Rules count: 9
        2 === to_html.size &&
        "\n " === to_html &&
        2 === text.to_s.size &&
        "\n " === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_18 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu\ >\ div\#search\-theme\-form\ >\ div\ >\ div\#search\.container\-inline\ >\ div\#edit\-search\-theme\-form\-keys\-wrapper\.form\-item\ >\ input\#edit\-search\-theme\-form\-keys\.form\-text$/

      def valid? # Rules count: 9
        183 === to_html.size &&
        "<input type=\"text\" maxlength=\"128\" name=\"search_theme_form_keys\" id=\"edit-search-theme-form-keys\" size=\"15\" value=\"\" title=\"Enter the terms you wish to search for.\" class=\"form-text\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "text" === node['type'] &&
128 === node['maxlength'] &&
"search_theme_form_keys" === node['name'] &&
"edit-search-theme-form-keys" === node['id'] &&
15 === node['size'] &&
"" === node['value'] &&
"Enter the terms you wish to search for." === node['title'] &&
"form-text" === node['class'] &&
        true
      end
    end
    class Element_19 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu\ >\ div\#search\-theme\-form\ >\ div\ >\ div\#search\.container\-inline\ >\ div\#edit\-search\-theme\-form\-keys\-wrapper\.form\-item$/

      def valid? # Rules count: 9
        256 === to_html.size &&
        "<div class=\"form-item\" id=\"edit-search-theme-form-keys-wrapper\">\n <input type=\"text\" maxlength=\"128\" name=\"search_theme_form_keys\" id=\"edit-search-theme-form-keys\" size=\"15\" value=\"\" title=\"Enter the terms you wish to search for.\" class=\"form-text\">\n</div>" === to_html &&
        2 === text.to_s.size &&
        "\n " === text.to_s &&
        2 === children.count &&
        (children_tags - ["text", "input"] == []) &&
        (children_classes - [nil, "form-text"] == []) &&
        (children_ids - [nil, "edit-search-theme-form-keys"] == []) &&
        "form-item" === node['class'] &&
"edit-search-theme-form-keys-wrapper" === node['id'] &&
        true
      end
    end
    class Element_20 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu\ >\ div\#search\-theme\-form\ >\ div\ >\ div\#search\.container\-inline\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_21 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu\ >\ div\#search\-theme\-form\ >\ div\ >\ div\#search\.container\-inline\ >\ input\#edit\-submit\.form\-submit$/

      def valid? # Rules count: 9
        83 === to_html.size &&
        "<input type=\"submit\" name=\"op\" id=\"edit-submit\" value=\"Search\" class=\"form-submit\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "submit" === node['type'] &&
"op" === node['name'] &&
"edit-submit" === node['id'] &&
"Search" === node['value'] &&
"form-submit" === node['class'] &&
        true
      end
    end
    class Element_22 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu\ >\ div\#search\-theme\-form\ >\ div\ >\ div\#search\.container\-inline\ >\ input\#edit\-search\-theme\-form$/

      def valid? # Rules count: 9
        90 === to_html.size &&
        "<input type=\"hidden\" name=\"form_id\" id=\"edit-search-theme-form\" value=\"search_theme_form\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "hidden" === node['type'] &&
"form_id" === node['name'] &&
"edit-search-theme-form" === node['id'] &&
"search_theme_form" === node['value'] &&
        true
      end
    end
    class Element_23 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu\ >\ div\#search\-theme\-form\ >\ div\ >\ div\#search\.container\-inline$/

      def valid? # Rules count: 9
        480 === to_html.size &&
        "<div id=\"search\" class=\"container-inline\">\n<div class=\"form-item\" id=\"edit-search-theme-form-keys-wrapper\">\n <input type=\"text\" maxlength=\"128\" name=\"search_theme_form_keys\" id=\"edit-search-theme-form-keys\" size=\"15\" value=\"\" title=\"Enter the terms you wish to search for.\" class=\"form-text\">\n</div>\n<input type=\"submit\" name=\"op\" id=\"edit-submit\" value=\"Search\" class=\"form-submit\"><input type=\"hidden\" name=\"form_id\" id=\"edit-search-theme-form\" value=\"search_theme_form\">\n</div>" === to_html &&
        3 === text.to_s.size &&
        "\n \n" === text.to_s &&
        4 === children.count &&
        (children_tags - ["div", "text", "input", "input"] == []) &&
        (children_classes - ["form-item", nil, "form-submit", nil] == []) &&
        (children_ids - ["edit-search-theme-form-keys-wrapper", nil, "edit-submit", "edit-search-theme-form"] == []) &&
        "search" === node['id'] &&
"container-inline" === node['class'] &&
        true
      end
    end
    class Element_24 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu\ >\ div\#search\-theme\-form\ >\ div\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_25 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu\ >\ div\#search\-theme\-form\ >\ div$/

      def valid? # Rules count: 9
        493 === to_html.size &&
        "<div>\n<div id=\"search\" class=\"container-inline\">\n<div class=\"form-item\" id=\"edit-search-theme-form-keys-wrapper\">\n <input type=\"text\" maxlength=\"128\" name=\"search_theme_form_keys\" id=\"edit-search-theme-form-keys\" size=\"15\" value=\"\" title=\"Enter the terms you wish to search for.\" class=\"form-text\">\n</div>\n<input type=\"submit\" name=\"op\" id=\"edit-submit\" value=\"Search\" class=\"form-submit\"><input type=\"hidden\" name=\"form_id\" id=\"edit-search-theme-form\" value=\"search_theme_form\">\n</div>\n</div>" === to_html &&
        4 === text.to_s.size &&
        "\n \n\n" === text.to_s &&
        2 === children.count &&
        (children_tags - ["div", "text"] == []) &&
        (children_classes - ["container-inline", nil] == []) &&
        (children_ids - ["search", nil] == []) &&
        
        true
      end
    end
    class Element_26 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu\ >\ div\#search\-theme\-form$/

      def valid? # Rules count: 9
        (609..674) === to_html.size &&
        /^<div\ style="display:none"\ action="\/tipitaka\/.*"\ accept\-charset="UTF\-8"\ method="post"\ id="search\-theme\-form">\n<div>\n<div\ id="search"\ class="container\-inline">\n<div\ class="form\-item"\ id="edit\-search\-theme\-form\-keys\-wrapper">\n\ <input\ type="text"\ maxlength="128"\ name="search_theme_form_keys"\ id="edit\-search\-theme\-form\-keys"\ size="15"\ value=""\ title="Enter\ the\ terms\ you\ wish\ to\ search\ for\."\ class="form\-text">\n<\/div>\n<input\ type="submit"\ name="op"\ id="edit\-submit"\ value="Search"\ class="form\-submit"><input\ type="hidden"\ name="form_id"\ id="edit\-search\-theme\-form"\ value="search_theme_form">\n<\/div>\n<\/div>\n<\/div>$/m === to_html &&
        6 === text.to_s.size &&
        "\n\n \n\n\n" === text.to_s &&
        3 === children.count &&
        (children_tags - ["text", "div", "text"] == []) &&
        (children_classes - [nil, nil, nil] == []) &&
        (children_ids - [nil, nil, nil] == []) &&
        "display:none" === node['style'] &&
/^\/tipitaka\/.*$/m === node['action'] &&
"UTF-8" === node['accept-charset'] &&
"post" === node['method'] &&
"search-theme-form" === node['id'] &&
        true
      end
    end
    class Element_27 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\#menu$/

      def valid? # Rules count: 9
        (645..710) === to_html.size &&
        /^<td\ id="menu">\n\ \ \ \ \ \ \ \ \ \ \ \ <div\ style="display:none"\ action="\/tipitaka\/.*"\ accept\-charset="UTF\-8"\ method="post"\ id="search\-theme\-form">\n<div>\n<div\ id="search"\ class="container\-inline">\n<div\ class="form\-item"\ id="edit\-search\-theme\-form\-keys\-wrapper">\n\ <input\ type="text"\ maxlength="128"\ name="search_theme_form_keys"\ id="edit\-search\-theme\-form\-keys"\ size="15"\ value=""\ title="Enter\ the\ terms\ you\ wish\ to\ search\ for\."\ class="form\-text">\n<\/div>\n<input\ type="submit"\ name="op"\ id="edit\-submit"\ value="Search"\ class="form\-submit"><input\ type="hidden"\ name="form_id"\ id="edit\-search\-theme\-form"\ value="search_theme_form">\n<\/div>\n<\/div>\n<\/div>\ \ \ \ <\/td>$/m === to_html &&
        23 === text.to_s.size &&
        "\n            \n\n \n\n\n    " === text.to_s &&
        3 === children.count &&
        (children_tags - ["text", "div", "text"] == []) &&
        (children_classes - [nil, nil, nil] == []) &&
        (children_ids - [nil, "search-theme-form", nil] == []) &&
        "menu" === node['id'] &&
        true
      end
    end
    class Element_28 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr$/

      def valid? # Rules count: 9
        (45..842) === to_html.size &&
        /^<tr>\n<td\ .*$/m === to_html &&
        Set[49, 3].include?(text.to_s.size) &&
        Set["\n            \n    \n    \n            \n\n \n\n\n    \n  ", "\n  "].include?(text.to_s) &&
        Set[4, 2].include?(children.count) &&
        Set[["td", "text", "td", "text"], ["td", "text"]].include?(children_tags) &&
        Set[[nil, nil, nil, nil], [nil, nil]].include?(children_classes) &&
        Set[["logo", nil, "menu", nil], [nil, nil]].include?(children_ids) &&
        
        true
      end
    end
    class Element_29 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td\ >\ div$/

      def valid? # Rules count: 9
        11 === to_html.size &&
        "<div></div>" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_30 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header\ >\ tr\ >\ td$/

      def valid? # Rules count: 9
        32 === to_html.size &&
        "<td colspan=\"2\"><div></div></td>" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        1 === children.count &&
        (children_tags - ["div"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        2 === node['colspan'] &&
        true
      end
    end
    class Element_31 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#header$/

      def valid? # Rules count: 9
        (895..960) === to_html.size &&
        /^<table\ border="0"\ cellpadding="1"\ cellspacing="0"\ id="header">\n<tr>\n<td\ id="logo">\n\ \ \ \ \ \ <a\ href="\/"\ title="Home"><img\ src="\/files\/founder3_logo\.gif"\ alt="Home"><\/a>\ \ \ \ \ \ \n\ \ \ \ <\/td>\n\ \ \ \ <td\ id="menu">\n\ \ \ \ \ \ \ \ \ \ \ \ <div\ style="display:none"\ action="\/tipitaka\/.*"\ accept\-charset="UTF\-8"\ method="post"\ id="search\-theme\-form">\n<div>\n<div\ id="search"\ class="container\-inline">\n<div\ class="form\-item"\ id="edit\-search\-theme\-form\-keys\-wrapper">\n\ <input\ type="text"\ maxlength="128"\ name="search_theme_form_keys"\ id="edit\-search\-theme\-form\-keys"\ size="15"\ value=""\ title="Enter\ the\ terms\ you\ wish\ to\ search\ for\."\ class="form\-text">\n<\/div>\n<input\ type="submit"\ name="op"\ id="edit\-submit"\ value="Search"\ class="form\-submit"><input\ type="hidden"\ name="form_id"\ id="edit\-search\-theme\-form"\ value="search_theme_form">\n<\/div>\n<\/div>\n<\/div>\ \ \ \ <\/td>\n\ \ <\/tr>\n<tr>\n<td\ colspan="2"><div><\/div><\/td>\n\ \ <\/tr>\n<\/table>\n$/m === to_html &&
        52 === text.to_s.size &&
        "\n            \n    \n    \n            \n\n \n\n\n    \n  \n  " === text.to_s &&
        2 === children.count &&
        (children_tags - ["tr", "tr"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        0 === node['border'] &&
1 === node['cellpadding'] &&
0 === node['cellspacing'] &&
"header" === node['id'] &&
        true
      end
    end
    class Element_32 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ text$/

      def valid? # Rules count: 9
        Set[8, 5].include?(to_html.size) &&
        Set["\n       ", "\n    "].include?(to_html) &&
        Set[8, 5].include?(text.to_s.size) &&
        Set["\n       ", "\n    "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_33 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ text$/

      def valid? # Rules count: 9
        Set[2, 3, 1].include?(to_html.size) &&
        Set["  ", "\n  ", "\n"].include?(to_html) &&
        Set[2, 3, 1].include?(text.to_s.size) &&
        Set["  ", "\n  ", "\n"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_34 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ text$/

      def valid? # Rules count: 9
        Set[5, 2].include?(to_html.size) &&
        Set["\n    ", "\n "].include?(to_html) &&
        Set[5, 2].include?(text.to_s.size) &&
        Set["\n    ", "\n "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_35 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ h2\.title\ >\ text$/

      def valid? # Rules count: 9
        (10..57) === to_html.size &&
        /^.*$/m === to_html &&
        (10..57) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_36 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ h2\.title$/

      def valid? # Rules count: 9
        (33..80) === to_html.size &&
        /^<h2\ class="title">.*<\/h2>$/m === to_html &&
        (10..57) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "title" === node['class'] &&
        true
      end
    end
    class Element_37 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.collapsed\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        36 === to_html.size &&
        "<img src=\"/misc/menu-collapsed.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-collapsed.png" === node['src'] &&
        true
      end
    end
    class Element_38 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.collapsed\ >\ a$/

      def valid? # Rules count: 9
        (50..85) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..43) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_39 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.collapsed\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (8..43) === to_html.size &&
        /^.*$/m === to_html &&
        (8..43) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_40 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.collapsed$/

      def valid? # Rules count: 9
        (191..226) === to_html.size &&
        /^<li\ class="collapsed"\ nid="2.*$/m === to_html &&
        (8..43) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["a", "a"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "collapsed" === node['class'] &&
(257314..271795) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_41 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu$/

      def valid? # Rules count: 9
        (214..27038) === to_html.size &&
        /^<ul\ class="menu">.*<\/ul>$/m === to_html &&
        (14..3176) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        (1..94) === children.count &&
        (children_tags - ["li"] == []) &&
        (children_classes - ["collapsed", "expanded", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf", "leaf"] == []) &&
        (children_ids - [nil] == []) &&
        "menu" === node['class'] &&
        true
      end
    end
    class Element_42 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content$/

      def valid? # Rules count: 9
        (241..27065) === to_html.size &&
        /^<div\ class="content">.*<\/div>$/m === to_html &&
        (14..3176) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        Set[1, 2].include?(children.count) &&
        Set[["ul"], ["form", "text"]].include?(children_tags) &&
        Set[["menu"], [nil, nil]].include?(children_classes) &&
        Set[[nil], ["tipitaka-quick-search-form", nil]].include?(children_ids) &&
        "content" === node['class'] &&
        true
      end
    end
    class Element_43 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka$/

      def valid? # Rules count: 9
        (353..27183) === to_html.size &&
        /^<div\ class="block\ block\-tipitaka"\ id="block\-tipitaka\-.*<\/div>\n\ <\/div>$/m === to_html &&
        (41..3245) === text.to_s.size &&
        /^\n\ \ \ \ .*\n\ $/m === text.to_s &&
        5 === children.count &&
        (children_tags - ["text", "h2", "text", "div", "text"] == []) &&
        (children_classes - [nil, "title", nil, "content", nil] == []) &&
        (children_ids - [nil, nil, nil, nil, nil] == []) &&
        "block block-tipitaka" === node['class'] &&
Set["block-tipitaka-0", "block-tipitaka-2"].include?(node['id']) &&
        true
      end
    end
    class Element_44 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ text$/

      def valid? # Rules count: 9
        Set[5, 2].include?(to_html.size) &&
        Set["\n    ", "\n "].include?(to_html) &&
        Set[5, 2].include?(text.to_s.size) &&
        Set["\n    ", "\n "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_45 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ h2\.title\ >\ text$/

      def valid? # Rules count: 9
        Set[30, 35].include?(to_html.size) &&
        Set["World Tipiṭaka Edition 40 Vols", "Chulachomklao of Siam Pāḷi Tipiṭaka", "Tipiṭaka Studies Reference Database", "World Tipiṭaka Pāḷi Recitation"].include?(to_html) &&
        Set[30, 35].include?(text.to_s.size) &&
        Set["World Tipiṭaka Edition 40 Vols", "Chulachomklao of Siam Pāḷi Tipiṭaka", "Tipiṭaka Studies Reference Database", "World Tipiṭaka Pāḷi Recitation"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_46 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ h2\.title$/

      def valid? # Rules count: 9
        Set[53, 58].include?(to_html.size) &&
        Set["<h2 class=\"title\">World Tipiṭaka Edition 40 Vols</h2>", "<h2 class=\"title\">Chulachomklao of Siam Pāḷi Tipiṭaka</h2>", "<h2 class=\"title\">Tipiṭaka Studies Reference Database</h2>", "<h2 class=\"title\">World Tipiṭaka Pāḷi Recitation</h2>"].include?(to_html) &&
        Set[30, 35].include?(text.to_s.size) &&
        Set["World Tipiṭaka Edition 40 Vols", "Chulachomklao of Siam Pāḷi Tipiṭaka", "Tipiṭaka Studies Reference Database", "World Tipiṭaka Pāḷi Recitation"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "title" === node['class'] &&
        true
      end
    end
    class Element_47 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ img$/

      def valid? # Rules count: 9
        Set[174, 225, 181, 77].include?(to_html.size) &&
        Set["<img src=\"http://farm4.static.flickr.com/3460/3214452019_7bab1c9035_t.jpg\" title=\"World Tipiṭaka Edition in Roman Script 40 Vols.\" alt=\"Pali Tipitaka\" height=\"93\" width=\"75\">", "<img src=\"http://farm4.static.flickr.com/3316/3425580567_73d8b68e3f_t.jpg\" alt=\"Chulachomklao of Siam Pāḷi Tipiṭaka\" title=\"Chulachomklao of Siam Pāḷi Tipiṭaka (1893) : A Digital Preservation Edition \" width=\"52\" height=\"90\">", "<img src=\"http://farm4.static.flickr.com/3542/3388928379_c7dbd65760_t.jpg\" alt=\"Tipitaka Studies Reference 2007\" title=\"Tipiṭaka Studies Reference 40 Vols.\" width=\"100\" height=\"76\">", "<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">"].include?(to_html) &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        Set["http://farm4.static.flickr.com/3460/3214452019_7bab1c9035_t.jpg", "http://farm4.static.flickr.com/3316/3425580567_73d8b68e3f_t.jpg", "http://farm4.static.flickr.com/3542/3388928379_c7dbd65760_t.jpg", "http://tipitakastudies.net/files/logo/speaker-icon.png"].include?(node['src']) &&
Set["World Tipiṭaka Edition in Roman Script 40 Vols.", "Chulachomklao of Siam Pāḷi Tipiṭaka (1893) : A Digital Preservation Edition ", "Tipiṭaka Studies Reference 40 Vols."].include?(node['title']) &&
Set["Pali Tipitaka", "Chulachomklao of Siam Pāḷi Tipiṭaka", "Tipitaka Studies Reference 2007"].include?(node['alt']) &&
Set[93, 90, 76].include?(node['height']) &&
Set[75, 52, 100, 20].include?(node['width']) &&
        true
      end
    end
    class Element_48 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td$/

      def valid? # Rules count: 9
        (35..602) === to_html.size &&
        /^<td.*<\/td>$/m === to_html &&
        Set[0, 126, 117, 194, 1, 23, 28, 38, 21].include?(text.to_s.size) &&
        Set["", "\n\n\n\t\t\t\tView\n\t\t\t\t\n\n\t\t\t\tTitle: Pāḷi Sound Order\n\t\t\t\t\n\n\t\t\t\tTitle: Roman-alphabet Order\n\t\t\t\t\n\n\t\t\t\tTitle: Tipiṭaka Structure\n\t\t\t\t\n\n", "\n\n\n\t\t\t\tSearch Siam/Roman script\n\t\t\t\t\n\n\t\t\t\tTipiṭaka Archive\n\t\t\t\t\n\n\t\t\t\tDigital Preservation\n\t\t\t\t\nTipiṭaka Documentary\n\n", "\n\n\n\t\t\t\tSearch Tipiṭaka Corpus\n\t\t\t\t\n\n\t\t\t\tNotes & References\n\t\t\t\t\n\n\t\t\t\tTechnical Pāḷi Terms\n\t\t\t\t\nTranslation Index\n                                \nSubject Index\n                                \n\n", " ", "\n", " Pātimokkha Recitation\n", " Pāḷi Recitation Dictionary\n", " International Phonetic Alphabet Pāḷi\n", " Tipiṭaka Recitation\n"].include?(text.to_s) &&
        Set[1, 3, 2].include?(children.count) &&
        Set[["img"], ["text", "div", "text"], ["text"], ["text", "img"], ["a", "text"]].include?(children_tags) &&
        Set[[nil], [nil, "item-list", nil], [nil, nil]].include?(children_classes) &&
        Set[[nil], [nil, nil, nil], [nil, nil]].include?(children_ids) &&
        "font-size:0.5em;" === node['style'] &&
        true
      end
    end
    class Element_49 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_50 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        Set["\n", " "].include?(to_html) &&
        1 === text.to_s.size &&
        Set["\n", " "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_51 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\.item\-list\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_52 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\.item\-list\ >\ ul\.menu\ >\ li\.leaf\ >\ text$/

      def valid? # Rules count: 9
        Set[5, 33].include?(to_html.size) &&
        Set["\n\t\t\t\t", "\n                                "].include?(to_html) &&
        Set[5, 33].include?(text.to_s.size) &&
        Set["\n\t\t\t\t", "\n                                "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_53 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\.item\-list\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        Set[4, 23, 27, 25, 24, 16, 20, 22, 17, 13].include?(to_html.size) &&
        /^.*$/m === to_html &&
        (4..27) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_54 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\.item\-list\ >\ ul\.menu\ >\ li\.leaf\ >\ a$/

      def valid? # Rules count: 9
        (42..163) === to_html.size &&
        /^<a\ href=".*<\/a>$/m === to_html &&
        (4..27) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        /^.*$/m === node['href'] &&
        true
      end
    end
    class Element_55 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\.item\-list\ >\ ul\.menu\ >\ li\.leaf$/

      def valid? # Rules count: 9
        (74..185) === to_html.size &&
        /^<li\ class="leaf">.*<\/li>$/m === to_html &&
        (14..50) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        Set[3, 1, 2].include?(children.count) &&
        Set[["text", "a", "text"], ["a"], ["a", "text"]].include?(children_tags) &&
        Set[[nil, nil, nil], [nil], [nil, nil]].include?(children_classes) &&
        Set[[nil, nil, nil], [nil], [nil, nil]].include?(children_ids) &&
        "leaf" === node['class'] &&
        true
      end
    end
    class Element_56 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\.item\-list\ >\ ul\.menu\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_57 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\.item\-list\ >\ ul\.menu$/

      def valid? # Rules count: 9
        Set[378, 560, 506].include?(to_html.size) &&
        Set["<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/content/view-and-quote\">View</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text_pali\">Title: Pāḷi Sound Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text\">Title: Roman-alphabet Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/toc_structure\">Title: Tipiṭaka Structure</a>\n\t\t\t\t</li>\n</ul>", "<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://hall.worldtipitaka.org/node/247253/\">Search Siam/Roman script</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://www.flickr.com/photos/dhammasociety/sets/\">Tipiṭaka Archive</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://society.worldtipitaka.org/mds/content/view/188/49/\">Digital Preservation</a>\n\t\t\t\t</li>\n<li class=\"leaf\"><a href=\"http://www.youtube.com/results?search_query=world%20tipitaka&amp;search=Search&amp;sa=X&amp;oi=spel%20l&amp;resnum=0&amp;spell=1\">Tipiṭaka Documentary</a></li>\n</ul>", "<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/corpus\">Search Tipiṭaka Corpus</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/all_note\">Notes &amp; References</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/all_term\">Technical Pāḷi Terms</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Translation Index</a>\n                                </li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Subject Index</a>\n                                </li>\n</ul>"].include?(to_html) &&
        Set[123, 114, 191].include?(text.to_s.size) &&
        Set["\n\t\t\t\tView\n\t\t\t\t\n\n\t\t\t\tTitle: Pāḷi Sound Order\n\t\t\t\t\n\n\t\t\t\tTitle: Roman-alphabet Order\n\t\t\t\t\n\n\t\t\t\tTitle: Tipiṭaka Structure\n\t\t\t\t\n", "\n\t\t\t\tSearch Siam/Roman script\n\t\t\t\t\n\n\t\t\t\tTipiṭaka Archive\n\t\t\t\t\n\n\t\t\t\tDigital Preservation\n\t\t\t\t\nTipiṭaka Documentary\n", "\n\t\t\t\tSearch Tipiṭaka Corpus\n\t\t\t\t\n\n\t\t\t\tNotes & References\n\t\t\t\t\n\n\t\t\t\tTechnical Pāḷi Terms\n\t\t\t\t\nTranslation Index\n                                \nSubject Index\n                                \n"].include?(text.to_s) &&
        Set[8, 10].include?(children.count) &&
        Set[["li", "text", "li", "text", "li", "text", "li", "text"], ["li", "text", "li", "text", "li", "text", "li", "text", "li", "text"]].include?(children_tags) &&
        Set[["leaf", nil, "leaf", nil, "leaf", nil, "leaf", nil], ["leaf", nil, "leaf", nil, "leaf", nil, "leaf", nil, "leaf", nil]].include?(children_classes) &&
        Set[[nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]].include?(children_ids) &&
        "menu" === node['class'] &&
        true
      end
    end
    class Element_58 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\.item\-list$/

      def valid? # Rules count: 9
        Set[409, 591, 537].include?(to_html.size) &&
        Set["<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/content/view-and-quote\">View</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text_pali\">Title: Pāḷi Sound Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text\">Title: Roman-alphabet Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/toc_structure\">Title: Tipiṭaka Structure</a>\n\t\t\t\t</li>\n</ul>\n</div>", "<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://hall.worldtipitaka.org/node/247253/\">Search Siam/Roman script</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://www.flickr.com/photos/dhammasociety/sets/\">Tipiṭaka Archive</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://society.worldtipitaka.org/mds/content/view/188/49/\">Digital Preservation</a>\n\t\t\t\t</li>\n<li class=\"leaf\"><a href=\"http://www.youtube.com/results?search_query=world%20tipitaka&amp;search=Search&amp;sa=X&amp;oi=spel%20l&amp;resnum=0&amp;spell=1\">Tipiṭaka Documentary</a></li>\n</ul>\n</div>", "<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/corpus\">Search Tipiṭaka Corpus</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/all_note\">Notes &amp; References</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/all_term\">Technical Pāḷi Terms</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Translation Index</a>\n                                </li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Subject Index</a>\n                                </li>\n</ul>\n</div>"].include?(to_html) &&
        Set[124, 115, 192].include?(text.to_s.size) &&
        Set["\n\n\t\t\t\tView\n\t\t\t\t\n\n\t\t\t\tTitle: Pāḷi Sound Order\n\t\t\t\t\n\n\t\t\t\tTitle: Roman-alphabet Order\n\t\t\t\t\n\n\t\t\t\tTitle: Tipiṭaka Structure\n\t\t\t\t\n", "\n\n\t\t\t\tSearch Siam/Roman script\n\t\t\t\t\n\n\t\t\t\tTipiṭaka Archive\n\t\t\t\t\n\n\t\t\t\tDigital Preservation\n\t\t\t\t\nTipiṭaka Documentary\n", "\n\n\t\t\t\tSearch Tipiṭaka Corpus\n\t\t\t\t\n\n\t\t\t\tNotes & References\n\t\t\t\t\n\n\t\t\t\tTechnical Pāḷi Terms\n\t\t\t\t\nTranslation Index\n                                \nSubject Index\n                                \n"].include?(text.to_s) &&
        2 === children.count &&
        (children_tags - ["text", "ul"] == []) &&
        (children_classes - [nil, "menu"] == []) &&
        (children_ids - [nil, nil] == []) &&
        "item-list" === node['class'] &&
        true
      end
    end
    class Element_59 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr$/

      def valid? # Rules count: 9
        Set[615, 848, 750, 72, 185, 218, 242, 228].include?(to_html.size) &&
        Set["<tr>\n<td><img src=\"http://farm4.static.flickr.com/3460/3214452019_7bab1c9035_t.jpg\" title=\"World Tipiṭaka Edition in Roman Script 40 Vols.\" alt=\"Pali Tipitaka\" height=\"93\" width=\"75\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/content/view-and-quote\">View</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text_pali\">Title: Pāḷi Sound Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text\">Title: Roman-alphabet Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/toc_structure\">Title: Tipiṭaka Structure</a>\n\t\t\t\t</li>\n</ul>\n</div>\n</td>\n</tr>", "<tr>\n<td><img src=\"http://farm4.static.flickr.com/3316/3425580567_73d8b68e3f_t.jpg\" alt=\"Chulachomklao of Siam Pāḷi Tipiṭaka\" title=\"Chulachomklao of Siam Pāḷi Tipiṭaka (1893) : A Digital Preservation Edition \" width=\"52\" height=\"90\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://hall.worldtipitaka.org/node/247253/\">Search Siam/Roman script</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://www.flickr.com/photos/dhammasociety/sets/\">Tipiṭaka Archive</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://society.worldtipitaka.org/mds/content/view/188/49/\">Digital Preservation</a>\n\t\t\t\t</li>\n<li class=\"leaf\"><a href=\"http://www.youtube.com/results?search_query=world%20tipitaka&amp;search=Search&amp;sa=X&amp;oi=spel%20l&amp;resnum=0&amp;spell=1\">Tipiṭaka Documentary</a></li>\n</ul>\n</div>\n</td>\n</tr>", "<tr>\n<td><img src=\"http://farm4.static.flickr.com/3542/3388928379_c7dbd65760_t.jpg\" alt=\"Tipitaka Studies Reference 2007\" title=\"Tipiṭaka Studies Reference 40 Vols.\" width=\"100\" height=\"76\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/corpus\">Search Tipiṭaka Corpus</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/all_note\">Notes &amp; References</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/all_term\">Technical Pāḷi Terms</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Translation Index</a>\n                                </li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Subject Index</a>\n                                </li>\n</ul>\n</div>\n</td>\n</tr>", "<tr style=\"font-size:0.5em;\">\n<td style=\"font-size:0.5em;\"> </td>\n</tr>\n", "<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"/Patimokkha\"> Pātimokkha Recitation</a>\n</td>\n</tr>\n", "<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a linkindex=\"144\" href=\"http://tipitakastudies.net/audio_alpha\" set=\"yes\"> Pāḷi Recitation Dictionary</a>\n</td>\n</tr>\n", "<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"http://www.dhammasociety.org/mds/content/view/167/45/\"> International Phonetic Alphabet Pāḷi</a>\n</td>\n</tr>\n", "<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"http://society.worldtipitaka.org/mds/content/view/100/44/\"> Tipiṭaka Recitation</a>\n</td>\n</tr>"].include?(to_html) &&
        Set[128, 119, 196, 2, 26, 31, 41, 24].include?(text.to_s.size) &&
        Set["\n\n\n\n\t\t\t\tView\n\t\t\t\t\n\n\t\t\t\tTitle: Pāḷi Sound Order\n\t\t\t\t\n\n\t\t\t\tTitle: Roman-alphabet Order\n\t\t\t\t\n\n\t\t\t\tTitle: Tipiṭaka Structure\n\t\t\t\t\n\n\n", "\n\n\n\n\t\t\t\tSearch Siam/Roman script\n\t\t\t\t\n\n\t\t\t\tTipiṭaka Archive\n\t\t\t\t\n\n\t\t\t\tDigital Preservation\n\t\t\t\t\nTipiṭaka Documentary\n\n\n", "\n\n\n\n\t\t\t\tSearch Tipiṭaka Corpus\n\t\t\t\t\n\n\t\t\t\tNotes & References\n\t\t\t\t\n\n\t\t\t\tTechnical Pāḷi Terms\n\t\t\t\t\nTranslation Index\n                                \nSubject Index\n                                \n\n\n", " \n", "\n\n Pātimokkha Recitation\n\n", "\n\n Pāḷi Recitation Dictionary\n\n", "\n\n International Phonetic Alphabet Pāḷi\n\n", "\n\n Tipiṭaka Recitation\n\n"].include?(text.to_s) &&
        Set[4, 2].include?(children.count) &&
        Set[["td", "text", "td", "text"], ["td", "text"]].include?(children_tags) &&
        Set[[nil, nil, nil, nil], [nil, nil]].include?(children_classes) &&
        Set[[nil, nil, nil, nil], [nil, nil]].include?(children_ids) &&
        "font-size:0.5em;" === node['style'] &&
        true
      end
    end
    class Element_60 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody$/

      def valid? # Rules count: 9
        Set[630, 892, 794, 985].include?(to_html.size) &&
        Set["<tbody><tr>\n<td><img src=\"http://farm4.static.flickr.com/3460/3214452019_7bab1c9035_t.jpg\" title=\"World Tipiṭaka Edition in Roman Script 40 Vols.\" alt=\"Pali Tipitaka\" height=\"93\" width=\"75\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/content/view-and-quote\">View</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text_pali\">Title: Pāḷi Sound Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text\">Title: Roman-alphabet Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/toc_structure\">Title: Tipiṭaka Structure</a>\n\t\t\t\t</li>\n</ul>\n</div>\n</td>\n</tr></tbody>", "<tbody style=\"border-top: 0px none\"><tr>\n<td><img src=\"http://farm4.static.flickr.com/3316/3425580567_73d8b68e3f_t.jpg\" alt=\"Chulachomklao of Siam Pāḷi Tipiṭaka\" title=\"Chulachomklao of Siam Pāḷi Tipiṭaka (1893) : A Digital Preservation Edition \" width=\"52\" height=\"90\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://hall.worldtipitaka.org/node/247253/\">Search Siam/Roman script</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://www.flickr.com/photos/dhammasociety/sets/\">Tipiṭaka Archive</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://society.worldtipitaka.org/mds/content/view/188/49/\">Digital Preservation</a>\n\t\t\t\t</li>\n<li class=\"leaf\"><a href=\"http://www.youtube.com/results?search_query=world%20tipitaka&amp;search=Search&amp;sa=X&amp;oi=spel%20l&amp;resnum=0&amp;spell=1\">Tipiṭaka Documentary</a></li>\n</ul>\n</div>\n</td>\n</tr></tbody>", "<tbody style=\"border-top: 0px none\"><tr>\n<td><img src=\"http://farm4.static.flickr.com/3542/3388928379_c7dbd65760_t.jpg\" alt=\"Tipitaka Studies Reference 2007\" title=\"Tipiṭaka Studies Reference 40 Vols.\" width=\"100\" height=\"76\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/corpus\">Search Tipiṭaka Corpus</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/all_note\">Notes &amp; References</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/all_term\">Technical Pāḷi Terms</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Translation Index</a>\n                                </li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Subject Index</a>\n                                </li>\n</ul>\n</div>\n</td>\n</tr></tbody>", "<tbody style=\"border-top:0px\">\n<tr style=\"font-size:0.5em;\">\n<td style=\"font-size:0.5em;\"> </td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"/Patimokkha\"> Pātimokkha Recitation</a>\n</td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a linkindex=\"144\" href=\"http://tipitakastudies.net/audio_alpha\" set=\"yes\"> Pāḷi Recitation Dictionary</a>\n</td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"http://www.dhammasociety.org/mds/content/view/167/45/\"> International Phonetic Alphabet Pāḷi</a>\n</td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"http://society.worldtipitaka.org/mds/content/view/100/44/\"> Tipiṭaka Recitation</a>\n</td>\n</tr>\n</tbody>"].include?(to_html) &&
        Set[128, 119, 196, 124].include?(text.to_s.size) &&
        Set["\n\n\n\n\t\t\t\tView\n\t\t\t\t\n\n\t\t\t\tTitle: Pāḷi Sound Order\n\t\t\t\t\n\n\t\t\t\tTitle: Roman-alphabet Order\n\t\t\t\t\n\n\t\t\t\tTitle: Tipiṭaka Structure\n\t\t\t\t\n\n\n", "\n\n\n\n\t\t\t\tSearch Siam/Roman script\n\t\t\t\t\n\n\t\t\t\tTipiṭaka Archive\n\t\t\t\t\n\n\t\t\t\tDigital Preservation\n\t\t\t\t\nTipiṭaka Documentary\n\n\n", "\n\n\n\n\t\t\t\tSearch Tipiṭaka Corpus\n\t\t\t\t\n\n\t\t\t\tNotes & References\n\t\t\t\t\n\n\t\t\t\tTechnical Pāḷi Terms\n\t\t\t\t\nTranslation Index\n                                \nSubject Index\n                                \n\n\n", " \n\n\n Pātimokkha Recitation\n\n\n\n Pāḷi Recitation Dictionary\n\n\n\n International Phonetic Alphabet Pāḷi\n\n\n\n Tipiṭaka Recitation\n\n"].include?(text.to_s) &&
        Set[1, 5].include?(children.count) &&
        Set[["tr"], ["tr", "tr", "tr", "tr", "tr"]].include?(children_tags) &&
        Set[[nil], [nil, nil, nil, nil, nil]].include?(children_classes) &&
        Set[[nil], [nil, nil, nil, nil, nil]].include?(children_ids) &&
        Set["border-top: 0px none", "border-top:0px"].include?(node['style']) &&
        true
      end
    end
    class Element_61 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table$/

      def valid? # Rules count: 9
        Set[676, 938, 840, 1000].include?(to_html.size) &&
        Set["<table border=\"2\" bordercolor=\"white\"><tbody><tr>\n<td><img src=\"http://farm4.static.flickr.com/3460/3214452019_7bab1c9035_t.jpg\" title=\"World Tipiṭaka Edition in Roman Script 40 Vols.\" alt=\"Pali Tipitaka\" height=\"93\" width=\"75\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/content/view-and-quote\">View</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text_pali\">Title: Pāḷi Sound Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text\">Title: Roman-alphabet Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/toc_structure\">Title: Tipiṭaka Structure</a>\n\t\t\t\t</li>\n</ul>\n</div>\n</td>\n</tr></tbody></table>", "<table border=\"1\" bordercolor=\"white\"><tbody style=\"border-top: 0px none\"><tr>\n<td><img src=\"http://farm4.static.flickr.com/3316/3425580567_73d8b68e3f_t.jpg\" alt=\"Chulachomklao of Siam Pāḷi Tipiṭaka\" title=\"Chulachomklao of Siam Pāḷi Tipiṭaka (1893) : A Digital Preservation Edition \" width=\"52\" height=\"90\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://hall.worldtipitaka.org/node/247253/\">Search Siam/Roman script</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://www.flickr.com/photos/dhammasociety/sets/\">Tipiṭaka Archive</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://society.worldtipitaka.org/mds/content/view/188/49/\">Digital Preservation</a>\n\t\t\t\t</li>\n<li class=\"leaf\"><a href=\"http://www.youtube.com/results?search_query=world%20tipitaka&amp;search=Search&amp;sa=X&amp;oi=spel%20l&amp;resnum=0&amp;spell=1\">Tipiṭaka Documentary</a></li>\n</ul>\n</div>\n</td>\n</tr></tbody></table>", "<table border=\"1\" bordercolor=\"white\"><tbody style=\"border-top: 0px none\"><tr>\n<td><img src=\"http://farm4.static.flickr.com/3542/3388928379_c7dbd65760_t.jpg\" alt=\"Tipitaka Studies Reference 2007\" title=\"Tipiṭaka Studies Reference 40 Vols.\" width=\"100\" height=\"76\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/corpus\">Search Tipiṭaka Corpus</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/all_note\">Notes &amp; References</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/all_term\">Technical Pāḷi Terms</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Translation Index</a>\n                                </li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Subject Index</a>\n                                </li>\n</ul>\n</div>\n</td>\n</tr></tbody></table>", "<table><tbody style=\"border-top:0px\">\n<tr style=\"font-size:0.5em;\">\n<td style=\"font-size:0.5em;\"> </td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"/Patimokkha\"> Pātimokkha Recitation</a>\n</td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a linkindex=\"144\" href=\"http://tipitakastudies.net/audio_alpha\" set=\"yes\"> Pāḷi Recitation Dictionary</a>\n</td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"http://www.dhammasociety.org/mds/content/view/167/45/\"> International Phonetic Alphabet Pāḷi</a>\n</td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"http://society.worldtipitaka.org/mds/content/view/100/44/\"> Tipiṭaka Recitation</a>\n</td>\n</tr>\n</tbody></table>"].include?(to_html) &&
        Set[128, 119, 196, 124].include?(text.to_s.size) &&
        Set["\n\n\n\n\t\t\t\tView\n\t\t\t\t\n\n\t\t\t\tTitle: Pāḷi Sound Order\n\t\t\t\t\n\n\t\t\t\tTitle: Roman-alphabet Order\n\t\t\t\t\n\n\t\t\t\tTitle: Tipiṭaka Structure\n\t\t\t\t\n\n\n", "\n\n\n\n\t\t\t\tSearch Siam/Roman script\n\t\t\t\t\n\n\t\t\t\tTipiṭaka Archive\n\t\t\t\t\n\n\t\t\t\tDigital Preservation\n\t\t\t\t\nTipiṭaka Documentary\n\n\n", "\n\n\n\n\t\t\t\tSearch Tipiṭaka Corpus\n\t\t\t\t\n\n\t\t\t\tNotes & References\n\t\t\t\t\n\n\t\t\t\tTechnical Pāḷi Terms\n\t\t\t\t\nTranslation Index\n                                \nSubject Index\n                                \n\n\n", " \n\n\n Pātimokkha Recitation\n\n\n\n Pāḷi Recitation Dictionary\n\n\n\n International Phonetic Alphabet Pāḷi\n\n\n\n Tipiṭaka Recitation\n\n"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["tbody"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set[2, 1].include?(node['border']) &&
"white" === node['bordercolor'] &&
        true
      end
    end
    class Element_62 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content$/

      def valid? # Rules count: 9
        Set[703, 965, 867, 1027].include?(to_html.size) &&
        Set["<div class=\"content\"><table border=\"2\" bordercolor=\"white\"><tbody><tr>\n<td><img src=\"http://farm4.static.flickr.com/3460/3214452019_7bab1c9035_t.jpg\" title=\"World Tipiṭaka Edition in Roman Script 40 Vols.\" alt=\"Pali Tipitaka\" height=\"93\" width=\"75\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/content/view-and-quote\">View</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text_pali\">Title: Pāḷi Sound Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text\">Title: Roman-alphabet Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/toc_structure\">Title: Tipiṭaka Structure</a>\n\t\t\t\t</li>\n</ul>\n</div>\n</td>\n</tr></tbody></table></div>", "<div class=\"content\"><table border=\"1\" bordercolor=\"white\"><tbody style=\"border-top: 0px none\"><tr>\n<td><img src=\"http://farm4.static.flickr.com/3316/3425580567_73d8b68e3f_t.jpg\" alt=\"Chulachomklao of Siam Pāḷi Tipiṭaka\" title=\"Chulachomklao of Siam Pāḷi Tipiṭaka (1893) : A Digital Preservation Edition \" width=\"52\" height=\"90\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://hall.worldtipitaka.org/node/247253/\">Search Siam/Roman script</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://www.flickr.com/photos/dhammasociety/sets/\">Tipiṭaka Archive</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://society.worldtipitaka.org/mds/content/view/188/49/\">Digital Preservation</a>\n\t\t\t\t</li>\n<li class=\"leaf\"><a href=\"http://www.youtube.com/results?search_query=world%20tipitaka&amp;search=Search&amp;sa=X&amp;oi=spel%20l&amp;resnum=0&amp;spell=1\">Tipiṭaka Documentary</a></li>\n</ul>\n</div>\n</td>\n</tr></tbody></table></div>", "<div class=\"content\"><table border=\"1\" bordercolor=\"white\"><tbody style=\"border-top: 0px none\"><tr>\n<td><img src=\"http://farm4.static.flickr.com/3542/3388928379_c7dbd65760_t.jpg\" alt=\"Tipitaka Studies Reference 2007\" title=\"Tipiṭaka Studies Reference 40 Vols.\" width=\"100\" height=\"76\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/corpus\">Search Tipiṭaka Corpus</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/all_note\">Notes &amp; References</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/all_term\">Technical Pāḷi Terms</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Translation Index</a>\n                                </li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Subject Index</a>\n                                </li>\n</ul>\n</div>\n</td>\n</tr></tbody></table></div>", "<div class=\"content\"><table><tbody style=\"border-top:0px\">\n<tr style=\"font-size:0.5em;\">\n<td style=\"font-size:0.5em;\"> </td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"/Patimokkha\"> Pātimokkha Recitation</a>\n</td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a linkindex=\"144\" href=\"http://tipitakastudies.net/audio_alpha\" set=\"yes\"> Pāḷi Recitation Dictionary</a>\n</td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"http://www.dhammasociety.org/mds/content/view/167/45/\"> International Phonetic Alphabet Pāḷi</a>\n</td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"http://society.worldtipitaka.org/mds/content/view/100/44/\"> Tipiṭaka Recitation</a>\n</td>\n</tr>\n</tbody></table></div>"].include?(to_html) &&
        Set[128, 119, 196, 124].include?(text.to_s.size) &&
        Set["\n\n\n\n\t\t\t\tView\n\t\t\t\t\n\n\t\t\t\tTitle: Pāḷi Sound Order\n\t\t\t\t\n\n\t\t\t\tTitle: Roman-alphabet Order\n\t\t\t\t\n\n\t\t\t\tTitle: Tipiṭaka Structure\n\t\t\t\t\n\n\n", "\n\n\n\n\t\t\t\tSearch Siam/Roman script\n\t\t\t\t\n\n\t\t\t\tTipiṭaka Archive\n\t\t\t\t\n\n\t\t\t\tDigital Preservation\n\t\t\t\t\nTipiṭaka Documentary\n\n\n", "\n\n\n\n\t\t\t\tSearch Tipiṭaka Corpus\n\t\t\t\t\n\n\t\t\t\tNotes & References\n\t\t\t\t\n\n\t\t\t\tTechnical Pāḷi Terms\n\t\t\t\t\nTranslation Index\n                                \nSubject Index\n                                \n\n\n", " \n\n\n Pātimokkha Recitation\n\n\n\n Pāḷi Recitation Dictionary\n\n\n\n International Phonetic Alphabet Pāḷi\n\n\n\n Tipiṭaka Recitation\n\n"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["table"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "content" === node['class'] &&
        true
      end
    end
    class Element_63 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block$/

      def valid? # Rules count: 9
        Set[824, 1092, 993, 1148].include?(to_html.size) &&
        Set["<div class=\"block block-block\" id=\"block-block-7\">\n    <h2 class=\"title\">World Tipiṭaka Edition 40 Vols</h2>\n    <div class=\"content\"><table border=\"2\" bordercolor=\"white\"><tbody><tr>\n<td><img src=\"http://farm4.static.flickr.com/3460/3214452019_7bab1c9035_t.jpg\" title=\"World Tipiṭaka Edition in Roman Script 40 Vols.\" alt=\"Pali Tipitaka\" height=\"93\" width=\"75\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/content/view-and-quote\">View</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text_pali\">Title: Pāḷi Sound Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/header_text\">Title: Roman-alphabet Order</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/toc_structure\">Title: Tipiṭaka Structure</a>\n\t\t\t\t</li>\n</ul>\n</div>\n</td>\n</tr></tbody></table></div>\n </div>", "<div class=\"block block-block\" id=\"block-block-13\">\n    <h2 class=\"title\">Chulachomklao of Siam Pāḷi Tipiṭaka</h2>\n    <div class=\"content\"><table border=\"1\" bordercolor=\"white\"><tbody style=\"border-top: 0px none\"><tr>\n<td><img src=\"http://farm4.static.flickr.com/3316/3425580567_73d8b68e3f_t.jpg\" alt=\"Chulachomklao of Siam Pāḷi Tipiṭaka\" title=\"Chulachomklao of Siam Pāḷi Tipiṭaka (1893) : A Digital Preservation Edition \" width=\"52\" height=\"90\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://hall.worldtipitaka.org/node/247253/\">Search Siam/Roman script</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://www.flickr.com/photos/dhammasociety/sets/\">Tipiṭaka Archive</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"http://society.worldtipitaka.org/mds/content/view/188/49/\">Digital Preservation</a>\n\t\t\t\t</li>\n<li class=\"leaf\"><a href=\"http://www.youtube.com/results?search_query=world%20tipitaka&amp;search=Search&amp;sa=X&amp;oi=spel%20l&amp;resnum=0&amp;spell=1\">Tipiṭaka Documentary</a></li>\n</ul>\n</div>\n</td>\n</tr></tbody></table></div>\n </div>", "<div class=\"block block-block\" id=\"block-block-6\">\n    <h2 class=\"title\">Tipiṭaka Studies Reference Database</h2>\n    <div class=\"content\"><table border=\"1\" bordercolor=\"white\"><tbody style=\"border-top: 0px none\"><tr>\n<td><img src=\"http://farm4.static.flickr.com/3542/3388928379_c7dbd65760_t.jpg\" alt=\"Tipitaka Studies Reference 2007\" title=\"Tipiṭaka Studies Reference 40 Vols.\" width=\"100\" height=\"76\"></td>\n<td>\n<div class=\"item-list\">\n<ul class=\"menu\">\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/corpus\">Search Tipiṭaka Corpus</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/all_note\">Notes &amp; References</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n\t\t\t\t<a href=\"/views/all_term\">Technical Pāḷi Terms</a>\n\t\t\t\t</li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Translation Index</a>\n                                </li>\n<li class=\"leaf\">\n<a href=\"/views/sikkhapada_translation_index\">Subject Index</a>\n                                </li>\n</ul>\n</div>\n</td>\n</tr></tbody></table></div>\n </div>", "<div class=\"block block-block\" id=\"block-block-4\">\n    <h2 class=\"title\">World Tipiṭaka Pāḷi Recitation</h2>\n    <div class=\"content\"><table><tbody style=\"border-top:0px\">\n<tr style=\"font-size:0.5em;\">\n<td style=\"font-size:0.5em;\"> </td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"/Patimokkha\"> Pātimokkha Recitation</a>\n</td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a linkindex=\"144\" href=\"http://tipitakastudies.net/audio_alpha\" set=\"yes\"> Pāḷi Recitation Dictionary</a>\n</td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"http://www.dhammasociety.org/mds/content/view/167/45/\"> International Phonetic Alphabet Pāḷi</a>\n</td>\n</tr>\n<tr>\n<td>\n<img width=\"20\" src=\"http://tipitakastudies.net/files/logo/speaker-icon.png\">\n</td>\n<td>\n<a set=\"yes\" linkindex=\"13\" href=\"http://society.worldtipitaka.org/mds/content/view/100/44/\"> Tipiṭaka Recitation</a>\n</td>\n</tr>\n</tbody></table></div>\n </div>"].include?(to_html) &&
        Set[170, 166, 243].include?(text.to_s.size) &&
        Set["\n    World Tipiṭaka Edition 40 Vols\n    \n\n\n\n\t\t\t\tView\n\t\t\t\t\n\n\t\t\t\tTitle: Pāḷi Sound Order\n\t\t\t\t\n\n\t\t\t\tTitle: Roman-alphabet Order\n\t\t\t\t\n\n\t\t\t\tTitle: Tipiṭaka Structure\n\t\t\t\t\n\n\n\n ", "\n    Chulachomklao of Siam Pāḷi Tipiṭaka\n    \n\n\n\n\t\t\t\tSearch Siam/Roman script\n\t\t\t\t\n\n\t\t\t\tTipiṭaka Archive\n\t\t\t\t\n\n\t\t\t\tDigital Preservation\n\t\t\t\t\nTipiṭaka Documentary\n\n\n\n ", "\n    Tipiṭaka Studies Reference Database\n    \n\n\n\n\t\t\t\tSearch Tipiṭaka Corpus\n\t\t\t\t\n\n\t\t\t\tNotes & References\n\t\t\t\t\n\n\t\t\t\tTechnical Pāḷi Terms\n\t\t\t\t\nTranslation Index\n                                \nSubject Index\n                                \n\n\n\n ", "\n    World Tipiṭaka Pāḷi Recitation\n     \n\n\n Pātimokkha Recitation\n\n\n\n Pāḷi Recitation Dictionary\n\n\n\n International Phonetic Alphabet Pāḷi\n\n\n\n Tipiṭaka Recitation\n\n\n "].include?(text.to_s) &&
        5 === children.count &&
        (children_tags - ["text", "h2", "text", "div", "text"] == []) &&
        (children_classes - [nil, "title", nil, "content", nil] == []) &&
        (children_ids - [nil, nil, nil, nil, nil] == []) &&
        "block block-block" === node['class'] &&
Set["block-block-7", "block-block-13", "block-block-6", "block-block-4"].include?(node['id']) &&
        true
      end
    end
    class Element_64 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        Set[22, 27, 37, 20].include?(to_html.size) &&
        Set[" Pātimokkha Recitation", " Pāḷi Recitation Dictionary", " International Phonetic Alphabet Pāḷi", " Tipiṭaka Recitation"].include?(to_html) &&
        Set[22, 27, 37, 20].include?(text.to_s.size) &&
        Set[" Pātimokkha Recitation", " Pāḷi Recitation Dictionary", " International Phonetic Alphabet Pāḷi", " Tipiṭaka Recitation"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_65 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-block\ >\ div\.content\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ a$/

      def valid? # Rules count: 9
        Set[73, 106, 130, 117].include?(to_html.size) &&
        Set["<a set=\"yes\" linkindex=\"13\" href=\"/Patimokkha\"> Pātimokkha Recitation</a>", "<a linkindex=\"144\" href=\"http://tipitakastudies.net/audio_alpha\" set=\"yes\"> Pāḷi Recitation Dictionary</a>", "<a set=\"yes\" linkindex=\"13\" href=\"http://www.dhammasociety.org/mds/content/view/167/45/\"> International Phonetic Alphabet Pāḷi</a>", "<a set=\"yes\" linkindex=\"13\" href=\"http://society.worldtipitaka.org/mds/content/view/100/44/\"> Tipiṭaka Recitation</a>"].include?(to_html) &&
        Set[22, 27, 37, 20].include?(text.to_s.size) &&
        Set[" Pātimokkha Recitation", " Pāḷi Recitation Dictionary", " International Phonetic Alphabet Pāḷi", " Tipiṭaka Recitation"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "yes" === node['set'] &&
Set[13, 144].include?(node['linkindex']) &&
Set["/Patimokkha", "http://tipitakastudies.net/audio_alpha", "http://www.dhammasociety.org/mds/content/view/167/45/", "http://society.worldtipitaka.org/mds/content/view/100/44/"].include?(node['href']) &&
        true
      end
    end
    class Element_66 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_67 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\#edit\-quick\-search\-from\-name\-wrapper\.form\-item\ >\ text$/

      def valid? # Rules count: 9
        2 === to_html.size &&
        "\n " === to_html &&
        2 === text.to_s.size &&
        "\n " === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_68 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\#edit\-quick\-search\-from\-name\-wrapper\.form\-item\ >\ select\#edit\-quick\-search\-from\-name\.form\-select\ >\ option\ >\ text$/

      def valid? # Rules count: 9
        Set[2, 3, 4, 5].include?(to_html.size) &&
        /^.*$/m === to_html &&
        Set[2, 3, 4, 5].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_69 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\#edit\-quick\-search\-from\-name\-wrapper\.form\-item\ >\ select\#edit\-quick\-search\-from\-name\.form\-select\ >\ option$/

      def valid? # Rules count: 9
        Set[31, 33, 35, 37, 36].include?(to_html.size) &&
        /^<option\ value=".*$/m === to_html &&
        Set[2, 3, 4, 5].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        /^.*$/m === node['value'] &&
        true
      end
    end
    class Element_70 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\#edit\-quick\-search\-from\-name\-wrapper\.form\-item\ >\ select\#edit\-quick\-search\-from\-name\.form\-select$/

      def valid? # Rules count: 9
        3185 === to_html.size &&
        "<select name=\"quick_search_from_name\" class=\"form-select\" id=\"edit-quick-search-from-name\"><option value=\"1V\">1V</option>\n<option value=\"2V\">2V</option>\n<option value=\"3V\">3V</option>\n<option value=\"4V\">4V</option>\n<option value=\"5V\">5V</option>\n<option value=\"6D\">6D</option>\n<option value=\"7D\">7D</option>\n<option value=\"8D\">8D</option>\n<option value=\"9M\">9M</option>\n<option value=\"10M\">10M</option>\n<option value=\"11M\">11M</option>\n<option value=\"12S1\">12S1</option>\n<option value=\"12S2\">12S2</option>\n<option value=\"13S3\">13S3</option>\n<option value=\"13S4\">13S4</option>\n<option value=\"14S5\">14S5</option>\n<option value=\"15A1\">15A1</option>\n<option value=\"15A2\">15A2</option>\n<option value=\"15A3\">15A3</option>\n<option value=\"15A4\">15A4</option>\n<option value=\"16A5\">16A5</option>\n<option value=\"16A6\">16A6</option>\n<option value=\"16A7\">16A7</option>\n<option value=\"17A8\">17A8</option>\n<option value=\"17A9\">17A9</option>\n<option value=\"17A10\">17A10</option>\n<option value=\"17A11\">17A11</option>\n<option value=\"18Kh\">18Kh</option>\n<option value=\"18Dh\">18Dh</option>\n<option value=\"18Ud\">18Ud</option>\n<option value=\"18It\">18It</option>\n<option value=\"18Sn\">18Sn</option>\n<option value=\"19Vv\">19Vv</option>\n<option value=\"19Pv\">19Pv</option>\n<option value=\"19Th1\">19Th1</option>\n<option value=\"19Th2\">19Th2</option>\n<option value=\"20Ap1\">20Ap1</option>\n<option value=\"20Ap2\">20Ap2</option>\n<option value=\"21Bu\">21Bu</option>\n<option value=\"21Cp\">21Cp</option>\n<option value=\"22J\">22J</option>\n<option value=\"23J\">23J</option>\n<option value=\"24Mn\">24Mn</option>\n<option value=\"25Cn\">25Cn</option>\n<option value=\"26Ps\">26Ps</option>\n<option value=\"27Ne\">27Ne</option>\n<option value=\"27Pe\">27Pe</option>\n<option value=\"28Mi\">28Mi</option>\n<option value=\"29Dhs\">29Dhs</option>\n<option value=\"30Vbh\">30Vbh</option>\n<option value=\"31Dht\">31Dht</option>\n<option value=\"31Pu\">31Pu</option>\n<option value=\"32Kv\">32Kv</option>\n<option value=\"33Y1\">33Y1</option>\n<option value=\"33Y2\">33Y2</option>\n<option value=\"33Y3\">33Y3</option>\n<option value=\"33Y4\">33Y4</option>\n<option value=\"33Y5\">33Y5</option>\n<option value=\"34Y6\">34Y6</option>\n<option value=\"34Y7\">34Y7</option>\n<option value=\"34Y8\">34Y8</option>\n<option value=\"35Y9\">35Y9</option>\n<option value=\"35Y10\">35Y10</option>\n<option value=\"36P1\">36P1</option>\n<option value=\"37P1\">37P1</option>\n<option value=\"38P2\">38P2</option>\n<option value=\"39P3\">39P3</option>\n<option value=\"39P4\">39P4</option>\n<option value=\"39P5\">39P5</option>\n<option value=\"39P6\">39P6</option>\n<option value=\"40P7\">40P7</option>\n<option value=\"40P8\">40P8</option>\n<option value=\"40P9\">40P9</option>\n<option value=\"40P10\">40P10</option>\n<option value=\"40P11\">40P11</option>\n<option value=\"40P12\">40P12</option>\n<option value=\"40P13\">40P13</option>\n<option value=\"40P14\">40P14</option>\n<option value=\"40P15\">40P15</option>\n<option value=\"40P16\">40P16</option>\n<option value=\"40P17\">40P17</option>\n<option value=\"40P18\">40P18</option>\n<option value=\"40P19\">40P19</option>\n<option value=\"40P20\">40P20</option>\n<option value=\"40P21\">40P21</option>\n<option value=\"40P22\">40P22</option>\n<option value=\"40P23\">40P23</option>\n<option value=\"40P24\">40P24</option></select>" === to_html &&
        355 === text.to_s.size &&
        "1V2V3V4V5V6D7D8D9M10M11M12S112S213S313S414S515A115A215A315A416A516A616A717A817A917A1017A1118Kh18Dh18Ud18It18Sn19Vv19Pv19Th119Th220Ap120Ap221Bu21Cp22J23J24Mn25Cn26Ps27Ne27Pe28Mi29Dhs30Vbh31Dht31Pu32Kv33Y133Y233Y333Y433Y534Y634Y734Y835Y935Y1036P137P138P239P339P439P539P640P740P840P940P1040P1140P1240P1340P1440P1540P1640P1740P1840P1940P2040P2140P2240P2340P24" === text.to_s &&
        88 === children.count &&
        (children_tags - ["option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option", "option"] == []) &&
        (children_classes - [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil] == []) &&
        (children_ids - [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil] == []) &&
        "quick_search_from_name" === node['name'] &&
"form-select" === node['class'] &&
"edit-quick-search-from-name" === node['id'] &&
        true
      end
    end
    class Element_71 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\#edit\-quick\-search\-from\-name\-wrapper\.form\-item$/

      def valid? # Rules count: 9
        3258 === to_html.size &&
        "<div class=\"form-item\" id=\"edit-quick-search-from-name-wrapper\">\n <select name=\"quick_search_from_name\" class=\"form-select\" id=\"edit-quick-search-from-name\"><option value=\"1V\">1V</option>\n<option value=\"2V\">2V</option>\n<option value=\"3V\">3V</option>\n<option value=\"4V\">4V</option>\n<option value=\"5V\">5V</option>\n<option value=\"6D\">6D</option>\n<option value=\"7D\">7D</option>\n<option value=\"8D\">8D</option>\n<option value=\"9M\">9M</option>\n<option value=\"10M\">10M</option>\n<option value=\"11M\">11M</option>\n<option value=\"12S1\">12S1</option>\n<option value=\"12S2\">12S2</option>\n<option value=\"13S3\">13S3</option>\n<option value=\"13S4\">13S4</option>\n<option value=\"14S5\">14S5</option>\n<option value=\"15A1\">15A1</option>\n<option value=\"15A2\">15A2</option>\n<option value=\"15A3\">15A3</option>\n<option value=\"15A4\">15A4</option>\n<option value=\"16A5\">16A5</option>\n<option value=\"16A6\">16A6</option>\n<option value=\"16A7\">16A7</option>\n<option value=\"17A8\">17A8</option>\n<option value=\"17A9\">17A9</option>\n<option value=\"17A10\">17A10</option>\n<option value=\"17A11\">17A11</option>\n<option value=\"18Kh\">18Kh</option>\n<option value=\"18Dh\">18Dh</option>\n<option value=\"18Ud\">18Ud</option>\n<option value=\"18It\">18It</option>\n<option value=\"18Sn\">18Sn</option>\n<option value=\"19Vv\">19Vv</option>\n<option value=\"19Pv\">19Pv</option>\n<option value=\"19Th1\">19Th1</option>\n<option value=\"19Th2\">19Th2</option>\n<option value=\"20Ap1\">20Ap1</option>\n<option value=\"20Ap2\">20Ap2</option>\n<option value=\"21Bu\">21Bu</option>\n<option value=\"21Cp\">21Cp</option>\n<option value=\"22J\">22J</option>\n<option value=\"23J\">23J</option>\n<option value=\"24Mn\">24Mn</option>\n<option value=\"25Cn\">25Cn</option>\n<option value=\"26Ps\">26Ps</option>\n<option value=\"27Ne\">27Ne</option>\n<option value=\"27Pe\">27Pe</option>\n<option value=\"28Mi\">28Mi</option>\n<option value=\"29Dhs\">29Dhs</option>\n<option value=\"30Vbh\">30Vbh</option>\n<option value=\"31Dht\">31Dht</option>\n<option value=\"31Pu\">31Pu</option>\n<option value=\"32Kv\">32Kv</option>\n<option value=\"33Y1\">33Y1</option>\n<option value=\"33Y2\">33Y2</option>\n<option value=\"33Y3\">33Y3</option>\n<option value=\"33Y4\">33Y4</option>\n<option value=\"33Y5\">33Y5</option>\n<option value=\"34Y6\">34Y6</option>\n<option value=\"34Y7\">34Y7</option>\n<option value=\"34Y8\">34Y8</option>\n<option value=\"35Y9\">35Y9</option>\n<option value=\"35Y10\">35Y10</option>\n<option value=\"36P1\">36P1</option>\n<option value=\"37P1\">37P1</option>\n<option value=\"38P2\">38P2</option>\n<option value=\"39P3\">39P3</option>\n<option value=\"39P4\">39P4</option>\n<option value=\"39P5\">39P5</option>\n<option value=\"39P6\">39P6</option>\n<option value=\"40P7\">40P7</option>\n<option value=\"40P8\">40P8</option>\n<option value=\"40P9\">40P9</option>\n<option value=\"40P10\">40P10</option>\n<option value=\"40P11\">40P11</option>\n<option value=\"40P12\">40P12</option>\n<option value=\"40P13\">40P13</option>\n<option value=\"40P14\">40P14</option>\n<option value=\"40P15\">40P15</option>\n<option value=\"40P16\">40P16</option>\n<option value=\"40P17\">40P17</option>\n<option value=\"40P18\">40P18</option>\n<option value=\"40P19\">40P19</option>\n<option value=\"40P20\">40P20</option>\n<option value=\"40P21\">40P21</option>\n<option value=\"40P22\">40P22</option>\n<option value=\"40P23\">40P23</option>\n<option value=\"40P24\">40P24</option></select>\n</div>" === to_html &&
        357 === text.to_s.size &&
        "\n 1V2V3V4V5V6D7D8D9M10M11M12S112S213S313S414S515A115A215A315A416A516A616A717A817A917A1017A1118Kh18Dh18Ud18It18Sn19Vv19Pv19Th119Th220Ap120Ap221Bu21Cp22J23J24Mn25Cn26Ps27Ne27Pe28Mi29Dhs30Vbh31Dht31Pu32Kv33Y133Y233Y333Y433Y534Y634Y734Y835Y935Y1036P137P138P239P339P439P539P640P740P840P940P1040P1140P1240P1340P1440P1540P1640P1740P1840P1940P2040P2140P2240P2340P24" === text.to_s &&
        2 === children.count &&
        (children_tags - ["text", "select"] == []) &&
        (children_classes - [nil, "form-select"] == []) &&
        (children_ids - [nil, "edit-quick-search-from-name"] == []) &&
        "form-item" === node['class'] &&
"edit-quick-search-from-name-wrapper" === node['id'] &&
        true
      end
    end
    class Element_72 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_73 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td$/

      def valid? # Rules count: 9
        Set[3270, 268, 146].include?(to_html.size) &&
        Set["<td>\n<div class=\"form-item\" id=\"edit-quick-search-from-name-wrapper\">\n <select name=\"quick_search_from_name\" class=\"form-select\" id=\"edit-quick-search-from-name\"><option value=\"1V\">1V</option>\n<option value=\"2V\">2V</option>\n<option value=\"3V\">3V</option>\n<option value=\"4V\">4V</option>\n<option value=\"5V\">5V</option>\n<option value=\"6D\">6D</option>\n<option value=\"7D\">7D</option>\n<option value=\"8D\">8D</option>\n<option value=\"9M\">9M</option>\n<option value=\"10M\">10M</option>\n<option value=\"11M\">11M</option>\n<option value=\"12S1\">12S1</option>\n<option value=\"12S2\">12S2</option>\n<option value=\"13S3\">13S3</option>\n<option value=\"13S4\">13S4</option>\n<option value=\"14S5\">14S5</option>\n<option value=\"15A1\">15A1</option>\n<option value=\"15A2\">15A2</option>\n<option value=\"15A3\">15A3</option>\n<option value=\"15A4\">15A4</option>\n<option value=\"16A5\">16A5</option>\n<option value=\"16A6\">16A6</option>\n<option value=\"16A7\">16A7</option>\n<option value=\"17A8\">17A8</option>\n<option value=\"17A9\">17A9</option>\n<option value=\"17A10\">17A10</option>\n<option value=\"17A11\">17A11</option>\n<option value=\"18Kh\">18Kh</option>\n<option value=\"18Dh\">18Dh</option>\n<option value=\"18Ud\">18Ud</option>\n<option value=\"18It\">18It</option>\n<option value=\"18Sn\">18Sn</option>\n<option value=\"19Vv\">19Vv</option>\n<option value=\"19Pv\">19Pv</option>\n<option value=\"19Th1\">19Th1</option>\n<option value=\"19Th2\">19Th2</option>\n<option value=\"20Ap1\">20Ap1</option>\n<option value=\"20Ap2\">20Ap2</option>\n<option value=\"21Bu\">21Bu</option>\n<option value=\"21Cp\">21Cp</option>\n<option value=\"22J\">22J</option>\n<option value=\"23J\">23J</option>\n<option value=\"24Mn\">24Mn</option>\n<option value=\"25Cn\">25Cn</option>\n<option value=\"26Ps\">26Ps</option>\n<option value=\"27Ne\">27Ne</option>\n<option value=\"27Pe\">27Pe</option>\n<option value=\"28Mi\">28Mi</option>\n<option value=\"29Dhs\">29Dhs</option>\n<option value=\"30Vbh\">30Vbh</option>\n<option value=\"31Dht\">31Dht</option>\n<option value=\"31Pu\">31Pu</option>\n<option value=\"32Kv\">32Kv</option>\n<option value=\"33Y1\">33Y1</option>\n<option value=\"33Y2\">33Y2</option>\n<option value=\"33Y3\">33Y3</option>\n<option value=\"33Y4\">33Y4</option>\n<option value=\"33Y5\">33Y5</option>\n<option value=\"34Y6\">34Y6</option>\n<option value=\"34Y7\">34Y7</option>\n<option value=\"34Y8\">34Y8</option>\n<option value=\"35Y9\">35Y9</option>\n<option value=\"35Y10\">35Y10</option>\n<option value=\"36P1\">36P1</option>\n<option value=\"37P1\">37P1</option>\n<option value=\"38P2\">38P2</option>\n<option value=\"39P3\">39P3</option>\n<option value=\"39P4\">39P4</option>\n<option value=\"39P5\">39P5</option>\n<option value=\"39P6\">39P6</option>\n<option value=\"40P7\">40P7</option>\n<option value=\"40P8\">40P8</option>\n<option value=\"40P9\">40P9</option>\n<option value=\"40P10\">40P10</option>\n<option value=\"40P11\">40P11</option>\n<option value=\"40P12\">40P12</option>\n<option value=\"40P13\">40P13</option>\n<option value=\"40P14\">40P14</option>\n<option value=\"40P15\">40P15</option>\n<option value=\"40P16\">40P16</option>\n<option value=\"40P17\">40P17</option>\n<option value=\"40P18\">40P18</option>\n<option value=\"40P19\">40P19</option>\n<option value=\"40P20\">40P20</option>\n<option value=\"40P21\">40P21</option>\n<option value=\"40P22\">40P22</option>\n<option value=\"40P23\">40P23</option>\n<option value=\"40P24\">40P24</option></select>\n</div>\n</td>\n", "<td>\n<div class=\"form-item\" id=\"edit-quick-search-from-number-wrapper\">\n <input type=\"text\" maxlength=\"128\" name=\"quick_search_from_number\" id=\"edit-quick-search-from-number\" size=\"10\" value=\"100\" class=\"form-text\"><div class=\"description\">e.g. 100</div>\n</div>\n</td>\n", "<td><div style=\"margin-bottom: 1em; margin-top: 1em;\"><input type=\"submit\" name=\"op\" id=\"edit-submit\" value=\"View\" class=\"form-submit\"></div></td>"].include?(to_html) &&
        Set[358, 12, 0].include?(text.to_s.size) &&
        Set["\n 1V2V3V4V5V6D7D8D9M10M11M12S112S213S313S414S515A115A215A315A416A516A616A717A817A917A1017A1118Kh18Dh18Ud18It18Sn19Vv19Pv19Th119Th220Ap120Ap221Bu21Cp22J23J24Mn25Cn26Ps27Ne27Pe28Mi29Dhs30Vbh31Dht31Pu32Kv33Y133Y233Y333Y433Y534Y634Y734Y835Y935Y1036P137P138P239P339P439P539P640P740P840P940P1040P1140P1240P1340P1440P1540P1640P1740P1840P1940P2040P2140P2240P2340P24\n", "\n e.g. 100\n\n", ""].include?(text.to_s) &&
        Set[2, 1].include?(children.count) &&
        Set[["div", "text"], ["div"]].include?(children_tags) &&
        Set[["form-item", nil], [nil]].include?(children_classes) &&
        Set[["edit-quick-search-from-name-wrapper", nil], ["edit-quick-search-from-number-wrapper", nil], [nil]].include?(children_ids) &&
        
        true
      end
    end
    class Element_74 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\#edit\-quick\-search\-from\-number\-wrapper\.form\-item\ >\ text$/

      def valid? # Rules count: 9
        Set[2, 1].include?(to_html.size) &&
        Set["\n ", "\n"].include?(to_html) &&
        Set[2, 1].include?(text.to_s.size) &&
        Set["\n ", "\n"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_75 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\#edit\-quick\-search\-from\-number\-wrapper\.form\-item\ >\ input\#edit\-quick\-search\-from\-number\.form\-text$/

      def valid? # Rules count: 9
        142 === to_html.size &&
        "<input type=\"text\" maxlength=\"128\" name=\"quick_search_from_number\" id=\"edit-quick-search-from-number\" size=\"10\" value=\"100\" class=\"form-text\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "text" === node['type'] &&
128 === node['maxlength'] &&
"quick_search_from_number" === node['name'] &&
"edit-quick-search-from-number" === node['id'] &&
10 === node['size'] &&
100 === node['value'] &&
"form-text" === node['class'] &&
        true
      end
    end
    class Element_76 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\#edit\-quick\-search\-from\-number\-wrapper\.form\-item\ >\ div\.description\ >\ text$/

      def valid? # Rules count: 9
        8 === to_html.size &&
        "e.g. 100" === to_html &&
        8 === text.to_s.size &&
        "e.g. 100" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_77 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\#edit\-quick\-search\-from\-number\-wrapper\.form\-item\ >\ div\.description$/

      def valid? # Rules count: 9
        39 === to_html.size &&
        "<div class=\"description\">e.g. 100</div>" === to_html &&
        8 === text.to_s.size &&
        "e.g. 100" === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "description" === node['class'] &&
        true
      end
    end
    class Element_78 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\#edit\-quick\-search\-from\-number\-wrapper\.form\-item$/

      def valid? # Rules count: 9
        256 === to_html.size &&
        "<div class=\"form-item\" id=\"edit-quick-search-from-number-wrapper\">\n <input type=\"text\" maxlength=\"128\" name=\"quick_search_from_number\" id=\"edit-quick-search-from-number\" size=\"10\" value=\"100\" class=\"form-text\"><div class=\"description\">e.g. 100</div>\n</div>" === to_html &&
        11 === text.to_s.size &&
        "\n e.g. 100\n" === text.to_s &&
        4 === children.count &&
        (children_tags - ["text", "input", "div", "text"] == []) &&
        (children_classes - [nil, "form-text", "description", nil] == []) &&
        (children_ids - [nil, "edit-quick-search-from-number", nil, nil] == []) &&
        "form-item" === node['class'] &&
"edit-quick-search-from-number-wrapper" === node['id'] &&
        true
      end
    end
    class Element_79 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div\ >\ input\#edit\-submit\.form\-submit$/

      def valid? # Rules count: 9
        81 === to_html.size &&
        "<input type=\"submit\" name=\"op\" id=\"edit-submit\" value=\"View\" class=\"form-submit\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "submit" === node['type'] &&
"op" === node['name'] &&
"edit-submit" === node['id'] &&
"View" === node['value'] &&
"form-submit" === node['class'] &&
        true
      end
    end
    class Element_80 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr\ >\ td\ >\ div$/

      def valid? # Rules count: 9
        137 === to_html.size &&
        "<div style=\"margin-bottom: 1em; margin-top: 1em;\"><input type=\"submit\" name=\"op\" id=\"edit-submit\" value=\"View\" class=\"form-submit\"></div>" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        1 === children.count &&
        (children_tags - ["input"] == []) &&
        (children_classes - ["form-submit"] == []) &&
        (children_ids - ["edit-submit"] == []) &&
        "margin-bottom: 1em; margin-top: 1em;" === node['style'] &&
        true
      end
    end
    class Element_81 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody\ >\ tr$/

      def valid? # Rules count: 9
        3708 === to_html.size &&
        "<tr valign=\"top\">\n<td>\n<div class=\"form-item\" id=\"edit-quick-search-from-name-wrapper\">\n <select name=\"quick_search_from_name\" class=\"form-select\" id=\"edit-quick-search-from-name\"><option value=\"1V\">1V</option>\n<option value=\"2V\">2V</option>\n<option value=\"3V\">3V</option>\n<option value=\"4V\">4V</option>\n<option value=\"5V\">5V</option>\n<option value=\"6D\">6D</option>\n<option value=\"7D\">7D</option>\n<option value=\"8D\">8D</option>\n<option value=\"9M\">9M</option>\n<option value=\"10M\">10M</option>\n<option value=\"11M\">11M</option>\n<option value=\"12S1\">12S1</option>\n<option value=\"12S2\">12S2</option>\n<option value=\"13S3\">13S3</option>\n<option value=\"13S4\">13S4</option>\n<option value=\"14S5\">14S5</option>\n<option value=\"15A1\">15A1</option>\n<option value=\"15A2\">15A2</option>\n<option value=\"15A3\">15A3</option>\n<option value=\"15A4\">15A4</option>\n<option value=\"16A5\">16A5</option>\n<option value=\"16A6\">16A6</option>\n<option value=\"16A7\">16A7</option>\n<option value=\"17A8\">17A8</option>\n<option value=\"17A9\">17A9</option>\n<option value=\"17A10\">17A10</option>\n<option value=\"17A11\">17A11</option>\n<option value=\"18Kh\">18Kh</option>\n<option value=\"18Dh\">18Dh</option>\n<option value=\"18Ud\">18Ud</option>\n<option value=\"18It\">18It</option>\n<option value=\"18Sn\">18Sn</option>\n<option value=\"19Vv\">19Vv</option>\n<option value=\"19Pv\">19Pv</option>\n<option value=\"19Th1\">19Th1</option>\n<option value=\"19Th2\">19Th2</option>\n<option value=\"20Ap1\">20Ap1</option>\n<option value=\"20Ap2\">20Ap2</option>\n<option value=\"21Bu\">21Bu</option>\n<option value=\"21Cp\">21Cp</option>\n<option value=\"22J\">22J</option>\n<option value=\"23J\">23J</option>\n<option value=\"24Mn\">24Mn</option>\n<option value=\"25Cn\">25Cn</option>\n<option value=\"26Ps\">26Ps</option>\n<option value=\"27Ne\">27Ne</option>\n<option value=\"27Pe\">27Pe</option>\n<option value=\"28Mi\">28Mi</option>\n<option value=\"29Dhs\">29Dhs</option>\n<option value=\"30Vbh\">30Vbh</option>\n<option value=\"31Dht\">31Dht</option>\n<option value=\"31Pu\">31Pu</option>\n<option value=\"32Kv\">32Kv</option>\n<option value=\"33Y1\">33Y1</option>\n<option value=\"33Y2\">33Y2</option>\n<option value=\"33Y3\">33Y3</option>\n<option value=\"33Y4\">33Y4</option>\n<option value=\"33Y5\">33Y5</option>\n<option value=\"34Y6\">34Y6</option>\n<option value=\"34Y7\">34Y7</option>\n<option value=\"34Y8\">34Y8</option>\n<option value=\"35Y9\">35Y9</option>\n<option value=\"35Y10\">35Y10</option>\n<option value=\"36P1\">36P1</option>\n<option value=\"37P1\">37P1</option>\n<option value=\"38P2\">38P2</option>\n<option value=\"39P3\">39P3</option>\n<option value=\"39P4\">39P4</option>\n<option value=\"39P5\">39P5</option>\n<option value=\"39P6\">39P6</option>\n<option value=\"40P7\">40P7</option>\n<option value=\"40P8\">40P8</option>\n<option value=\"40P9\">40P9</option>\n<option value=\"40P10\">40P10</option>\n<option value=\"40P11\">40P11</option>\n<option value=\"40P12\">40P12</option>\n<option value=\"40P13\">40P13</option>\n<option value=\"40P14\">40P14</option>\n<option value=\"40P15\">40P15</option>\n<option value=\"40P16\">40P16</option>\n<option value=\"40P17\">40P17</option>\n<option value=\"40P18\">40P18</option>\n<option value=\"40P19\">40P19</option>\n<option value=\"40P20\">40P20</option>\n<option value=\"40P21\">40P21</option>\n<option value=\"40P22\">40P22</option>\n<option value=\"40P23\">40P23</option>\n<option value=\"40P24\">40P24</option></select>\n</div>\n</td>\n<td>\n<div class=\"form-item\" id=\"edit-quick-search-from-number-wrapper\">\n <input type=\"text\" maxlength=\"128\" name=\"quick_search_from_number\" id=\"edit-quick-search-from-number\" size=\"10\" value=\"100\" class=\"form-text\"><div class=\"description\">e.g. 100</div>\n</div>\n</td>\n<td><div style=\"margin-bottom: 1em; margin-top: 1em;\"><input type=\"submit\" name=\"op\" id=\"edit-submit\" value=\"View\" class=\"form-submit\"></div></td>\n</tr>" === to_html &&
        370 === text.to_s.size &&
        "\n 1V2V3V4V5V6D7D8D9M10M11M12S112S213S313S414S515A115A215A315A416A516A616A717A817A917A1017A1118Kh18Dh18Ud18It18Sn19Vv19Pv19Th119Th220Ap120Ap221Bu21Cp22J23J24Mn25Cn26Ps27Ne27Pe28Mi29Dhs30Vbh31Dht31Pu32Kv33Y133Y233Y333Y433Y534Y634Y734Y835Y935Y1036P137P138P239P339P439P539P640P740P840P940P1040P1140P1240P1340P1440P1540P1640P1740P1840P1940P2040P2140P2240P2340P24\n\n e.g. 100\n\n" === text.to_s &&
        3 === children.count &&
        (children_tags - ["td", "td", "td"] == []) &&
        (children_classes - [nil, nil, nil] == []) &&
        (children_ids - [nil, nil, nil] == []) &&
        "top" === node['valign'] &&
        true
      end
    end
    class Element_82 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table\ >\ tbody$/

      def valid? # Rules count: 9
        3746 === to_html.size &&
        "<tbody style=\"border-top:0px\"><tr valign=\"top\">\n<td>\n<div class=\"form-item\" id=\"edit-quick-search-from-name-wrapper\">\n <select name=\"quick_search_from_name\" class=\"form-select\" id=\"edit-quick-search-from-name\"><option value=\"1V\">1V</option>\n<option value=\"2V\">2V</option>\n<option value=\"3V\">3V</option>\n<option value=\"4V\">4V</option>\n<option value=\"5V\">5V</option>\n<option value=\"6D\">6D</option>\n<option value=\"7D\">7D</option>\n<option value=\"8D\">8D</option>\n<option value=\"9M\">9M</option>\n<option value=\"10M\">10M</option>\n<option value=\"11M\">11M</option>\n<option value=\"12S1\">12S1</option>\n<option value=\"12S2\">12S2</option>\n<option value=\"13S3\">13S3</option>\n<option value=\"13S4\">13S4</option>\n<option value=\"14S5\">14S5</option>\n<option value=\"15A1\">15A1</option>\n<option value=\"15A2\">15A2</option>\n<option value=\"15A3\">15A3</option>\n<option value=\"15A4\">15A4</option>\n<option value=\"16A5\">16A5</option>\n<option value=\"16A6\">16A6</option>\n<option value=\"16A7\">16A7</option>\n<option value=\"17A8\">17A8</option>\n<option value=\"17A9\">17A9</option>\n<option value=\"17A10\">17A10</option>\n<option value=\"17A11\">17A11</option>\n<option value=\"18Kh\">18Kh</option>\n<option value=\"18Dh\">18Dh</option>\n<option value=\"18Ud\">18Ud</option>\n<option value=\"18It\">18It</option>\n<option value=\"18Sn\">18Sn</option>\n<option value=\"19Vv\">19Vv</option>\n<option value=\"19Pv\">19Pv</option>\n<option value=\"19Th1\">19Th1</option>\n<option value=\"19Th2\">19Th2</option>\n<option value=\"20Ap1\">20Ap1</option>\n<option value=\"20Ap2\">20Ap2</option>\n<option value=\"21Bu\">21Bu</option>\n<option value=\"21Cp\">21Cp</option>\n<option value=\"22J\">22J</option>\n<option value=\"23J\">23J</option>\n<option value=\"24Mn\">24Mn</option>\n<option value=\"25Cn\">25Cn</option>\n<option value=\"26Ps\">26Ps</option>\n<option value=\"27Ne\">27Ne</option>\n<option value=\"27Pe\">27Pe</option>\n<option value=\"28Mi\">28Mi</option>\n<option value=\"29Dhs\">29Dhs</option>\n<option value=\"30Vbh\">30Vbh</option>\n<option value=\"31Dht\">31Dht</option>\n<option value=\"31Pu\">31Pu</option>\n<option value=\"32Kv\">32Kv</option>\n<option value=\"33Y1\">33Y1</option>\n<option value=\"33Y2\">33Y2</option>\n<option value=\"33Y3\">33Y3</option>\n<option value=\"33Y4\">33Y4</option>\n<option value=\"33Y5\">33Y5</option>\n<option value=\"34Y6\">34Y6</option>\n<option value=\"34Y7\">34Y7</option>\n<option value=\"34Y8\">34Y8</option>\n<option value=\"35Y9\">35Y9</option>\n<option value=\"35Y10\">35Y10</option>\n<option value=\"36P1\">36P1</option>\n<option value=\"37P1\">37P1</option>\n<option value=\"38P2\">38P2</option>\n<option value=\"39P3\">39P3</option>\n<option value=\"39P4\">39P4</option>\n<option value=\"39P5\">39P5</option>\n<option value=\"39P6\">39P6</option>\n<option value=\"40P7\">40P7</option>\n<option value=\"40P8\">40P8</option>\n<option value=\"40P9\">40P9</option>\n<option value=\"40P10\">40P10</option>\n<option value=\"40P11\">40P11</option>\n<option value=\"40P12\">40P12</option>\n<option value=\"40P13\">40P13</option>\n<option value=\"40P14\">40P14</option>\n<option value=\"40P15\">40P15</option>\n<option value=\"40P16\">40P16</option>\n<option value=\"40P17\">40P17</option>\n<option value=\"40P18\">40P18</option>\n<option value=\"40P19\">40P19</option>\n<option value=\"40P20\">40P20</option>\n<option value=\"40P21\">40P21</option>\n<option value=\"40P22\">40P22</option>\n<option value=\"40P23\">40P23</option>\n<option value=\"40P24\">40P24</option></select>\n</div>\n</td>\n<td>\n<div class=\"form-item\" id=\"edit-quick-search-from-number-wrapper\">\n <input type=\"text\" maxlength=\"128\" name=\"quick_search_from_number\" id=\"edit-quick-search-from-number\" size=\"10\" value=\"100\" class=\"form-text\"><div class=\"description\">e.g. 100</div>\n</div>\n</td>\n<td><div style=\"margin-bottom: 1em; margin-top: 1em;\"><input type=\"submit\" name=\"op\" id=\"edit-submit\" value=\"View\" class=\"form-submit\"></div></td>\n</tr></tbody>" === to_html &&
        370 === text.to_s.size &&
        "\n 1V2V3V4V5V6D7D8D9M10M11M12S112S213S313S414S515A115A215A315A416A516A616A717A817A917A1017A1118Kh18Dh18Ud18It18Sn19Vv19Pv19Th119Th220Ap120Ap221Bu21Cp22J23J24Mn25Cn26Ps27Ne27Pe28Mi29Dhs30Vbh31Dht31Pu32Kv33Y133Y233Y333Y433Y534Y634Y734Y835Y935Y1036P137P138P239P339P439P539P640P740P840P940P1040P1140P1240P1340P1440P1540P1640P1740P1840P1940P2040P2140P2240P2340P24\n\n e.g. 100\n\n" === text.to_s &&
        1 === children.count &&
        (children_tags - ["tr"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "border-top:0px" === node['style'] &&
        true
      end
    end
    class Element_83 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ table$/

      def valid? # Rules count: 9
        3762 === to_html.size &&
        "<table><tbody style=\"border-top:0px\"><tr valign=\"top\">\n<td>\n<div class=\"form-item\" id=\"edit-quick-search-from-name-wrapper\">\n <select name=\"quick_search_from_name\" class=\"form-select\" id=\"edit-quick-search-from-name\"><option value=\"1V\">1V</option>\n<option value=\"2V\">2V</option>\n<option value=\"3V\">3V</option>\n<option value=\"4V\">4V</option>\n<option value=\"5V\">5V</option>\n<option value=\"6D\">6D</option>\n<option value=\"7D\">7D</option>\n<option value=\"8D\">8D</option>\n<option value=\"9M\">9M</option>\n<option value=\"10M\">10M</option>\n<option value=\"11M\">11M</option>\n<option value=\"12S1\">12S1</option>\n<option value=\"12S2\">12S2</option>\n<option value=\"13S3\">13S3</option>\n<option value=\"13S4\">13S4</option>\n<option value=\"14S5\">14S5</option>\n<option value=\"15A1\">15A1</option>\n<option value=\"15A2\">15A2</option>\n<option value=\"15A3\">15A3</option>\n<option value=\"15A4\">15A4</option>\n<option value=\"16A5\">16A5</option>\n<option value=\"16A6\">16A6</option>\n<option value=\"16A7\">16A7</option>\n<option value=\"17A8\">17A8</option>\n<option value=\"17A9\">17A9</option>\n<option value=\"17A10\">17A10</option>\n<option value=\"17A11\">17A11</option>\n<option value=\"18Kh\">18Kh</option>\n<option value=\"18Dh\">18Dh</option>\n<option value=\"18Ud\">18Ud</option>\n<option value=\"18It\">18It</option>\n<option value=\"18Sn\">18Sn</option>\n<option value=\"19Vv\">19Vv</option>\n<option value=\"19Pv\">19Pv</option>\n<option value=\"19Th1\">19Th1</option>\n<option value=\"19Th2\">19Th2</option>\n<option value=\"20Ap1\">20Ap1</option>\n<option value=\"20Ap2\">20Ap2</option>\n<option value=\"21Bu\">21Bu</option>\n<option value=\"21Cp\">21Cp</option>\n<option value=\"22J\">22J</option>\n<option value=\"23J\">23J</option>\n<option value=\"24Mn\">24Mn</option>\n<option value=\"25Cn\">25Cn</option>\n<option value=\"26Ps\">26Ps</option>\n<option value=\"27Ne\">27Ne</option>\n<option value=\"27Pe\">27Pe</option>\n<option value=\"28Mi\">28Mi</option>\n<option value=\"29Dhs\">29Dhs</option>\n<option value=\"30Vbh\">30Vbh</option>\n<option value=\"31Dht\">31Dht</option>\n<option value=\"31Pu\">31Pu</option>\n<option value=\"32Kv\">32Kv</option>\n<option value=\"33Y1\">33Y1</option>\n<option value=\"33Y2\">33Y2</option>\n<option value=\"33Y3\">33Y3</option>\n<option value=\"33Y4\">33Y4</option>\n<option value=\"33Y5\">33Y5</option>\n<option value=\"34Y6\">34Y6</option>\n<option value=\"34Y7\">34Y7</option>\n<option value=\"34Y8\">34Y8</option>\n<option value=\"35Y9\">35Y9</option>\n<option value=\"35Y10\">35Y10</option>\n<option value=\"36P1\">36P1</option>\n<option value=\"37P1\">37P1</option>\n<option value=\"38P2\">38P2</option>\n<option value=\"39P3\">39P3</option>\n<option value=\"39P4\">39P4</option>\n<option value=\"39P5\">39P5</option>\n<option value=\"39P6\">39P6</option>\n<option value=\"40P7\">40P7</option>\n<option value=\"40P8\">40P8</option>\n<option value=\"40P9\">40P9</option>\n<option value=\"40P10\">40P10</option>\n<option value=\"40P11\">40P11</option>\n<option value=\"40P12\">40P12</option>\n<option value=\"40P13\">40P13</option>\n<option value=\"40P14\">40P14</option>\n<option value=\"40P15\">40P15</option>\n<option value=\"40P16\">40P16</option>\n<option value=\"40P17\">40P17</option>\n<option value=\"40P18\">40P18</option>\n<option value=\"40P19\">40P19</option>\n<option value=\"40P20\">40P20</option>\n<option value=\"40P21\">40P21</option>\n<option value=\"40P22\">40P22</option>\n<option value=\"40P23\">40P23</option>\n<option value=\"40P24\">40P24</option></select>\n</div>\n</td>\n<td>\n<div class=\"form-item\" id=\"edit-quick-search-from-number-wrapper\">\n <input type=\"text\" maxlength=\"128\" name=\"quick_search_from_number\" id=\"edit-quick-search-from-number\" size=\"10\" value=\"100\" class=\"form-text\"><div class=\"description\">e.g. 100</div>\n</div>\n</td>\n<td><div style=\"margin-bottom: 1em; margin-top: 1em;\"><input type=\"submit\" name=\"op\" id=\"edit-submit\" value=\"View\" class=\"form-submit\"></div></td>\n</tr></tbody></table>\n" === to_html &&
        370 === text.to_s.size &&
        "\n 1V2V3V4V5V6D7D8D9M10M11M12S112S213S313S414S515A115A215A315A416A516A616A717A817A917A1017A1118Kh18Dh18Ud18It18Sn19Vv19Pv19Th119Th220Ap120Ap221Bu21Cp22J23J24Mn25Cn26Ps27Ne27Pe28Mi29Dhs30Vbh31Dht31Pu32Kv33Y133Y233Y333Y433Y534Y634Y734Y835Y935Y1036P137P138P239P339P439P539P640P740P840P940P1040P1140P1240P1340P1440P1540P1640P1740P1840P1940P2040P2140P2240P2340P24\n\n e.g. 100\n\n" === text.to_s &&
        1 === children.count &&
        (children_tags - ["tbody"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        
        true
      end
    end
    class Element_84 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div\ >\ input\#edit\-tipitaka\-quick\-search\-form$/

      def valid? # Rules count: 9
        108 === to_html.size &&
        "<input type=\"hidden\" name=\"form_id\" id=\"edit-tipitaka-quick-search-form\" value=\"tipitaka_quick_search_form\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "hidden" === node['type'] &&
"form_id" === node['name'] &&
"edit-tipitaka-quick-search-form" === node['id'] &&
"tipitaka_quick_search_form" === node['value'] &&
        true
      end
    end
    class Element_85 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form\ >\ div$/

      def valid? # Rules count: 9
        3883 === to_html.size &&
        "<div>\n<table><tbody style=\"border-top:0px\"><tr valign=\"top\">\n<td>\n<div class=\"form-item\" id=\"edit-quick-search-from-name-wrapper\">\n <select name=\"quick_search_from_name\" class=\"form-select\" id=\"edit-quick-search-from-name\"><option value=\"1V\">1V</option>\n<option value=\"2V\">2V</option>\n<option value=\"3V\">3V</option>\n<option value=\"4V\">4V</option>\n<option value=\"5V\">5V</option>\n<option value=\"6D\">6D</option>\n<option value=\"7D\">7D</option>\n<option value=\"8D\">8D</option>\n<option value=\"9M\">9M</option>\n<option value=\"10M\">10M</option>\n<option value=\"11M\">11M</option>\n<option value=\"12S1\">12S1</option>\n<option value=\"12S2\">12S2</option>\n<option value=\"13S3\">13S3</option>\n<option value=\"13S4\">13S4</option>\n<option value=\"14S5\">14S5</option>\n<option value=\"15A1\">15A1</option>\n<option value=\"15A2\">15A2</option>\n<option value=\"15A3\">15A3</option>\n<option value=\"15A4\">15A4</option>\n<option value=\"16A5\">16A5</option>\n<option value=\"16A6\">16A6</option>\n<option value=\"16A7\">16A7</option>\n<option value=\"17A8\">17A8</option>\n<option value=\"17A9\">17A9</option>\n<option value=\"17A10\">17A10</option>\n<option value=\"17A11\">17A11</option>\n<option value=\"18Kh\">18Kh</option>\n<option value=\"18Dh\">18Dh</option>\n<option value=\"18Ud\">18Ud</option>\n<option value=\"18It\">18It</option>\n<option value=\"18Sn\">18Sn</option>\n<option value=\"19Vv\">19Vv</option>\n<option value=\"19Pv\">19Pv</option>\n<option value=\"19Th1\">19Th1</option>\n<option value=\"19Th2\">19Th2</option>\n<option value=\"20Ap1\">20Ap1</option>\n<option value=\"20Ap2\">20Ap2</option>\n<option value=\"21Bu\">21Bu</option>\n<option value=\"21Cp\">21Cp</option>\n<option value=\"22J\">22J</option>\n<option value=\"23J\">23J</option>\n<option value=\"24Mn\">24Mn</option>\n<option value=\"25Cn\">25Cn</option>\n<option value=\"26Ps\">26Ps</option>\n<option value=\"27Ne\">27Ne</option>\n<option value=\"27Pe\">27Pe</option>\n<option value=\"28Mi\">28Mi</option>\n<option value=\"29Dhs\">29Dhs</option>\n<option value=\"30Vbh\">30Vbh</option>\n<option value=\"31Dht\">31Dht</option>\n<option value=\"31Pu\">31Pu</option>\n<option value=\"32Kv\">32Kv</option>\n<option value=\"33Y1\">33Y1</option>\n<option value=\"33Y2\">33Y2</option>\n<option value=\"33Y3\">33Y3</option>\n<option value=\"33Y4\">33Y4</option>\n<option value=\"33Y5\">33Y5</option>\n<option value=\"34Y6\">34Y6</option>\n<option value=\"34Y7\">34Y7</option>\n<option value=\"34Y8\">34Y8</option>\n<option value=\"35Y9\">35Y9</option>\n<option value=\"35Y10\">35Y10</option>\n<option value=\"36P1\">36P1</option>\n<option value=\"37P1\">37P1</option>\n<option value=\"38P2\">38P2</option>\n<option value=\"39P3\">39P3</option>\n<option value=\"39P4\">39P4</option>\n<option value=\"39P5\">39P5</option>\n<option value=\"39P6\">39P6</option>\n<option value=\"40P7\">40P7</option>\n<option value=\"40P8\">40P8</option>\n<option value=\"40P9\">40P9</option>\n<option value=\"40P10\">40P10</option>\n<option value=\"40P11\">40P11</option>\n<option value=\"40P12\">40P12</option>\n<option value=\"40P13\">40P13</option>\n<option value=\"40P14\">40P14</option>\n<option value=\"40P15\">40P15</option>\n<option value=\"40P16\">40P16</option>\n<option value=\"40P17\">40P17</option>\n<option value=\"40P18\">40P18</option>\n<option value=\"40P19\">40P19</option>\n<option value=\"40P20\">40P20</option>\n<option value=\"40P21\">40P21</option>\n<option value=\"40P22\">40P22</option>\n<option value=\"40P23\">40P23</option>\n<option value=\"40P24\">40P24</option></select>\n</div>\n</td>\n<td>\n<div class=\"form-item\" id=\"edit-quick-search-from-number-wrapper\">\n <input type=\"text\" maxlength=\"128\" name=\"quick_search_from_number\" id=\"edit-quick-search-from-number\" size=\"10\" value=\"100\" class=\"form-text\"><div class=\"description\">e.g. 100</div>\n</div>\n</td>\n<td><div style=\"margin-bottom: 1em; margin-top: 1em;\"><input type=\"submit\" name=\"op\" id=\"edit-submit\" value=\"View\" class=\"form-submit\"></div></td>\n</tr></tbody></table>\n<input type=\"hidden\" name=\"form_id\" id=\"edit-tipitaka-quick-search-form\" value=\"tipitaka_quick_search_form\">\n</div>" === to_html &&
        370 === text.to_s.size &&
        "\n 1V2V3V4V5V6D7D8D9M10M11M12S112S213S313S414S515A115A215A315A416A516A616A717A817A917A1017A1118Kh18Dh18Ud18It18Sn19Vv19Pv19Th119Th220Ap120Ap221Bu21Cp22J23J24Mn25Cn26Ps27Ne27Pe28Mi29Dhs30Vbh31Dht31Pu32Kv33Y133Y233Y333Y433Y534Y634Y734Y835Y935Y1036P137P138P239P339P439P539P640P740P840P940P1040P1140P1240P1340P1440P1540P1640P1740P1840P1940P2040P2140P2240P2340P24\n\n e.g. 100\n\n" === text.to_s &&
        2 === children.count &&
        (children_tags - ["table", "input"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, "edit-tipitaka-quick-search-form"] == []) &&
        
        true
      end
    end
    class Element_86 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ form\#tipitaka\-quick\-search\-form$/

      def valid? # Rules count: 9
        (3989..4054) === to_html.size &&
        /^<form\ action="\/tipitaka\/.*"\ accept\-charset="UTF\-8"\ method="post"\ id="tipitaka\-quick\-search\-form">\n<div>\n<table><tbody\ style="border\-top:0px"><tr\ valign="top">\n<td>\n<div\ class="form\-item"\ id="edit\-quick\-search\-from\-name\-wrapper">\n\ <select\ name="quick_search_from_name"\ class="form\-select"\ id="edit\-quick\-search\-from\-name"><option\ value="1V">1V<\/option>\n<option\ value="2V">2V<\/option>\n<option\ value="3V">3V<\/option>\n<option\ value="4V">4V<\/option>\n<option\ value="5V">5V<\/option>\n<option\ value="6D">6D<\/option>\n<option\ value="7D">7D<\/option>\n<option\ value="8D">8D<\/option>\n<option\ value="9M">9M<\/option>\n<option\ value="10M">10M<\/option>\n<option\ value="11M">11M<\/option>\n<option\ value="12S1">12S1<\/option>\n<option\ value="12S2">12S2<\/option>\n<option\ value="13S3">13S3<\/option>\n<option\ value="13S4">13S4<\/option>\n<option\ value="14S5">14S5<\/option>\n<option\ value="15A1">15A1<\/option>\n<option\ value="15A2">15A2<\/option>\n<option\ value="15A3">15A3<\/option>\n<option\ value="15A4">15A4<\/option>\n<option\ value="16A5">16A5<\/option>\n<option\ value="16A6">16A6<\/option>\n<option\ value="16A7">16A7<\/option>\n<option\ value="17A8">17A8<\/option>\n<option\ value="17A9">17A9<\/option>\n<option\ value="17A10">17A10<\/option>\n<option\ value="17A11">17A11<\/option>\n<option\ value="18Kh">18Kh<\/option>\n<option\ value="18Dh">18Dh<\/option>\n<option\ value="18Ud">18Ud<\/option>\n<option\ value="18It">18It<\/option>\n<option\ value="18Sn">18Sn<\/option>\n<option\ value="19Vv">19Vv<\/option>\n<option\ value="19Pv">19Pv<\/option>\n<option\ value="19Th1">19Th1<\/option>\n<option\ value="19Th2">19Th2<\/option>\n<option\ value="20Ap1">20Ap1<\/option>\n<option\ value="20Ap2">20Ap2<\/option>\n<option\ value="21Bu">21Bu<\/option>\n<option\ value="21Cp">21Cp<\/option>\n<option\ value="22J">22J<\/option>\n<option\ value="23J">23J<\/option>\n<option\ value="24Mn">24Mn<\/option>\n<option\ value="25Cn">25Cn<\/option>\n<option\ value="26Ps">26Ps<\/option>\n<option\ value="27Ne">27Ne<\/option>\n<option\ value="27Pe">27Pe<\/option>\n<option\ value="28Mi">28Mi<\/option>\n<option\ value="29Dhs">29Dhs<\/option>\n<option\ value="30Vbh">30Vbh<\/option>\n<option\ value="31Dht">31Dht<\/option>\n<option\ value="31Pu">31Pu<\/option>\n<option\ value="32Kv">32Kv<\/option>\n<option\ value="33Y1">33Y1<\/option>\n<option\ value="33Y2">33Y2<\/option>\n<option\ value="33Y3">33Y3<\/option>\n<option\ value="33Y4">33Y4<\/option>\n<option\ value="33Y5">33Y5<\/option>\n<option\ value="34Y6">34Y6<\/option>\n<option\ value="34Y7">34Y7<\/option>\n<option\ value="34Y8">34Y8<\/option>\n<option\ value="35Y9">35Y9<\/option>\n<option\ value="35Y10">35Y10<\/option>\n<option\ value="36P1">36P1<\/option>\n<option\ value="37P1">37P1<\/option>\n<option\ value="38P2">38P2<\/option>\n<option\ value="39P3">39P3<\/option>\n<option\ value="39P4">39P4<\/option>\n<option\ value="39P5">39P5<\/option>\n<option\ value="39P6">39P6<\/option>\n<option\ value="40P7">40P7<\/option>\n<option\ value="40P8">40P8<\/option>\n<option\ value="40P9">40P9<\/option>\n<option\ value="40P10">40P10<\/option>\n<option\ value="40P11">40P11<\/option>\n<option\ value="40P12">40P12<\/option>\n<option\ value="40P13">40P13<\/option>\n<option\ value="40P14">40P14<\/option>\n<option\ value="40P15">40P15<\/option>\n<option\ value="40P16">40P16<\/option>\n<option\ value="40P17">40P17<\/option>\n<option\ value="40P18">40P18<\/option>\n<option\ value="40P19">40P19<\/option>\n<option\ value="40P20">40P20<\/option>\n<option\ value="40P21">40P21<\/option>\n<option\ value="40P22">40P22<\/option>\n<option\ value="40P23">40P23<\/option>\n<option\ value="40P24">40P24<\/option><\/select>\n<\/div>\n<\/td>\n<td>\n<div\ class="form\-item"\ id="edit\-quick\-search\-from\-number\-wrapper">\n\ <input\ type="text"\ maxlength="128"\ name="quick_search_from_number"\ id="edit\-quick\-search\-from\-number"\ size="10"\ value="100"\ class="form\-text"><div\ class="description">e\.g\.\ 100<\/div>\n<\/div>\n<\/td>\n<td><div\ style="margin\-bottom:\ 1em;\ margin\-top:\ 1em;"><input\ type="submit"\ name="op"\ id="edit\-submit"\ value="View"\ class="form\-submit"><\/div><\/td>\n<\/tr><\/tbody><\/table>\n<input\ type="hidden"\ name="form_id"\ id="edit\-tipitaka\-quick\-search\-form"\ value="tipitaka_quick_search_form">\n<\/div>\n<\/form>$/m === to_html &&
        371 === text.to_s.size &&
        "\n\n 1V2V3V4V5V6D7D8D9M10M11M12S112S213S313S414S515A115A215A315A416A516A616A717A817A917A1017A1118Kh18Dh18Ud18It18Sn19Vv19Pv19Th119Th220Ap120Ap221Bu21Cp22J23J24Mn25Cn26Ps27Ne27Pe28Mi29Dhs30Vbh31Dht31Pu32Kv33Y133Y233Y333Y433Y534Y634Y734Y835Y935Y1036P137P138P239P339P439P539P640P740P840P940P1040P1140P1240P1340P1440P1540P1640P1740P1840P1940P2040P2140P2240P2340P24\n\n e.g. 100\n\n" === text.to_s &&
        2 === children.count &&
        (children_tags - ["text", "div"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        /^\/tipitaka\/.*$/m === node['action'] &&
"UTF-8" === node['accept-charset'] &&
"post" === node['method'] &&
"tipitaka-quick-search-form" === node['id'] &&
        true
      end
    end
    class Element_87 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_88 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ text$/

      def valid? # Rules count: 9
        Set[5, 2].include?(to_html.size) &&
        Set["\n    ", "\n "].include?(to_html) &&
        Set[5, 2].include?(text.to_s.size) &&
        Set["\n    ", "\n "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_89 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ h2\.title\ >\ text$/

      def valid? # Rules count: 9
        10 === to_html.size &&
        Set["Navigation", "User login"].include?(to_html) &&
        10 === text.to_s.size &&
        Set["Navigation", "User login"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_90 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ h2\.title$/

      def valid? # Rules count: 9
        33 === to_html.size &&
        Set["<h2 class=\"title\">Navigation</h2>", "<h2 class=\"title\">User login</h2>"].include?(to_html) &&
        10 === text.to_s.size &&
        Set["Navigation", "User login"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "title" === node['class'] &&
        true
      end
    end
    class Element_91 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_92 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        5 === to_html.size &&
        "Audio" === to_html &&
        5 === text.to_s.size &&
        "Audio" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_93 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ ul\.menu\ >\ li\.leaf\ >\ a$/

      def valid? # Rules count: 9
        31 === to_html.size &&
        "<a href=\"/Patimokkha\">Audio</a>" === to_html &&
        5 === text.to_s.size &&
        "Audio" === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "/Patimokkha" === node['href'] &&
        true
      end
    end
    class Element_94 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ ul\.menu\ >\ li\.leaf$/

      def valid? # Rules count: 9
        53 === to_html.size &&
        "<li class=\"leaf\"><a href=\"/Patimokkha\">Audio</a></li>" === to_html &&
        5 === text.to_s.size &&
        "Audio" === text.to_s &&
        1 === children.count &&
        (children_tags - ["a"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "leaf" === node['class'] &&
        true
      end
    end
    class Element_95 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ ul\.menu\ >\ text$/

      def valid? # Rules count: 9
        2 === to_html.size &&
        "\n\n" === to_html &&
        2 === text.to_s.size &&
        "\n\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_96 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ ul\.menu$/

      def valid? # Rules count: 9
        78 === to_html.size &&
        "<ul class=\"menu\">\n<li class=\"leaf\"><a href=\"/Patimokkha\">Audio</a></li>\n\n</ul>" === to_html &&
        7 === text.to_s.size &&
        "Audio\n\n" === text.to_s &&
        2 === children.count &&
        (children_tags - ["li", "text"] == []) &&
        (children_classes - ["leaf", nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "menu" === node['class'] &&
        true
      end
    end
    class Element_97 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content$/

      def valid? # Rules count: 9
        (107..1174) === to_html.size &&
        /^<div\ class="content">\n<.*>\n<\/div>$/m === to_html &&
        Set[8, 72].include?(text.to_s.size) &&
        Set["\nAudio\n\n", "\n\n Username: *\n \n\n Password: *\n \nCreate new accountRequest new password\n"].include?(text.to_s) &&
        2 === children.count &&
        Set[["text", "ul"], ["form", "text"]].include?(children_tags) &&
        Set[[nil, "menu"], [nil, nil]].include?(children_classes) &&
        Set[[nil, nil], ["user-login-form", nil]].include?(children_ids) &&
        "content" === node['class'] &&
        true
      end
    end
    class Element_98 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user$/

      def valid? # Rules count: 9
        (206..1273) === to_html.size &&
        /^<div\ class="block\ block\-user"\ id="block\-user\-.*>\n<\/div>\n\ <\/div>$/m === to_html &&
        Set[30, 94].include?(text.to_s.size) &&
        Set["\n    Navigation\n    \nAudio\n\n\n ", "\n    User login\n    \n\n Username: *\n \n\n Password: *\n \nCreate new accountRequest new password\n\n "].include?(text.to_s) &&
        5 === children.count &&
        (children_tags - ["text", "h2", "text", "div", "text"] == []) &&
        (children_classes - [nil, "title", nil, "content", nil] == []) &&
        (children_ids - [nil, nil, nil, nil, nil] == []) &&
        "block block-user" === node['class'] &&
Set["block-user-1", "block-user-0"].include?(node['id']) &&
        true
      end
    end
    class Element_99 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_100 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-name\-wrapper\.form\-item\ >\ text$/

      def valid? # Rules count: 9
        2 === to_html.size &&
        "\n " === to_html &&
        2 === text.to_s.size &&
        "\n " === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_101 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-name\-wrapper\.form\-item\ >\ label\ >\ text$/

      def valid? # Rules count: 9
        10 === to_html.size &&
        "Username: " === to_html &&
        10 === text.to_s.size &&
        "Username: " === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_102 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-name\-wrapper\.form\-item\ >\ label\ >\ span\.form\-required\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "*" === to_html &&
        1 === text.to_s.size &&
        "*" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_103 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-name\-wrapper\.form\-item\ >\ label\ >\ span\.form\-required$/

      def valid? # Rules count: 9
        68 === to_html.size &&
        "<span class=\"form-required\" title=\"This field is required.\">*</span>" === to_html &&
        1 === text.to_s.size &&
        "*" === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "form-required" === node['class'] &&
"This field is required." === node['title'] &&
        true
      end
    end
    class Element_104 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-name\-wrapper\.form\-item\ >\ label$/

      def valid? # Rules count: 9
        109 === to_html.size &&
        "<label for=\"edit-name\">Username: <span class=\"form-required\" title=\"This field is required.\">*</span></label>" === to_html &&
        11 === text.to_s.size &&
        "Username: *" === text.to_s &&
        2 === children.count &&
        (children_tags - ["text", "span"] == []) &&
        (children_classes - [nil, "form-required"] == []) &&
        (children_ids - [nil, nil] == []) &&
        "edit-name" === node['for'] &&
        true
      end
    end
    class Element_105 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-name\-wrapper\.form\-item\ >\ input\#edit\-name\.form\-text\ required$/

      def valid? # Rules count: 9
        107 === to_html.size &&
        "<input type=\"text\" maxlength=\"60\" name=\"name\" id=\"edit-name\" size=\"15\" value=\"\" class=\"form-text required\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "text" === node['type'] &&
60 === node['maxlength'] &&
"name" === node['name'] &&
"edit-name" === node['id'] &&
15 === node['size'] &&
"" === node['value'] &&
"form-text required" === node['class'] &&
        true
      end
    end
    class Element_106 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-name\-wrapper\.form\-item$/

      def valid? # Rules count: 9
        273 === to_html.size &&
        "<div class=\"form-item\" id=\"edit-name-wrapper\">\n <label for=\"edit-name\">Username: <span class=\"form-required\" title=\"This field is required.\">*</span></label>\n <input type=\"text\" maxlength=\"60\" name=\"name\" id=\"edit-name\" size=\"15\" value=\"\" class=\"form-text required\">\n</div>" === to_html &&
        15 === text.to_s.size &&
        "\n Username: *\n " === text.to_s &&
        4 === children.count &&
        (children_tags - ["text", "label", "text", "input"] == []) &&
        (children_classes - [nil, nil, nil, "form-text required"] == []) &&
        (children_ids - [nil, nil, nil, "edit-name"] == []) &&
        "form-item" === node['class'] &&
"edit-name-wrapper" === node['id'] &&
        true
      end
    end
    class Element_107 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_108 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-pass\-wrapper\.form\-item\ >\ text$/

      def valid? # Rules count: 9
        2 === to_html.size &&
        "\n " === to_html &&
        2 === text.to_s.size &&
        "\n " === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_109 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-pass\-wrapper\.form\-item\ >\ label\ >\ text$/

      def valid? # Rules count: 9
        10 === to_html.size &&
        "Password: " === to_html &&
        10 === text.to_s.size &&
        "Password: " === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_110 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-pass\-wrapper\.form\-item\ >\ label\ >\ span\.form\-required\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "*" === to_html &&
        1 === text.to_s.size &&
        "*" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_111 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-pass\-wrapper\.form\-item\ >\ label\ >\ span\.form\-required$/

      def valid? # Rules count: 9
        68 === to_html.size &&
        "<span class=\"form-required\" title=\"This field is required.\">*</span>" === to_html &&
        1 === text.to_s.size &&
        "*" === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "form-required" === node['class'] &&
"This field is required." === node['title'] &&
        true
      end
    end
    class Element_112 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-pass\-wrapper\.form\-item\ >\ label$/

      def valid? # Rules count: 9
        109 === to_html.size &&
        "<label for=\"edit-pass\">Password: <span class=\"form-required\" title=\"This field is required.\">*</span></label>" === to_html &&
        11 === text.to_s.size &&
        "Password: *" === text.to_s &&
        2 === children.count &&
        (children_tags - ["text", "span"] == []) &&
        (children_classes - [nil, "form-required"] == []) &&
        (children_ids - [nil, nil] == []) &&
        "edit-pass" === node['for'] &&
        true
      end
    end
    class Element_113 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-pass\-wrapper\.form\-item\ >\ input\#edit\-pass\.form\-text\ required$/

      def valid? # Rules count: 9
        102 === to_html.size &&
        "<input type=\"password\" name=\"pass\" id=\"edit-pass\" maxlength=\"60\" size=\"15\" class=\"form-text required\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "password" === node['type'] &&
"pass" === node['name'] &&
"edit-pass" === node['id'] &&
60 === node['maxlength'] &&
15 === node['size'] &&
"form-text required" === node['class'] &&
        true
      end
    end
    class Element_114 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\#edit\-pass\-wrapper\.form\-item$/

      def valid? # Rules count: 9
        268 === to_html.size &&
        "<div class=\"form-item\" id=\"edit-pass-wrapper\">\n <label for=\"edit-pass\">Password: <span class=\"form-required\" title=\"This field is required.\">*</span></label>\n <input type=\"password\" name=\"pass\" id=\"edit-pass\" maxlength=\"60\" size=\"15\" class=\"form-text required\">\n</div>" === to_html &&
        15 === text.to_s.size &&
        "\n Password: *\n " === text.to_s &&
        4 === children.count &&
        (children_tags - ["text", "label", "text", "input"] == []) &&
        (children_classes - [nil, nil, nil, "form-text required"] == []) &&
        (children_ids - [nil, nil, nil, "edit-pass"] == []) &&
        "form-item" === node['class'] &&
"edit-pass-wrapper" === node['id'] &&
        true
      end
    end
    class Element_115 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ input\#edit\-submit\.form\-submit$/

      def valid? # Rules count: 9
        83 === to_html.size &&
        "<input type=\"submit\" name=\"op\" id=\"edit-submit\" value=\"Log in\" class=\"form-submit\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "submit" === node['type'] &&
"op" === node['name'] &&
"edit-submit" === node['id'] &&
"Log in" === node['value'] &&
"form-submit" === node['class'] &&
        true
      end
    end
    class Element_116 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\.item\-list\ >\ ul\ >\ li\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        Set[18, 20].include?(to_html.size) &&
        Set["Create new account", "Request new password"].include?(to_html) &&
        Set[18, 20].include?(text.to_s.size) &&
        Set["Create new account", "Request new password"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_117 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\.item\-list\ >\ ul\ >\ li\ >\ a$/

      def valid? # Rules count: 9
        Set[82, 90].include?(to_html.size) &&
        Set["<a href=\"/user/register\" title=\"Create a new user account.\">Create new account</a>", "<a href=\"/user/password\" title=\"Request new password via e-mail.\">Request new password</a>"].include?(to_html) &&
        Set[18, 20].include?(text.to_s.size) &&
        Set["Create new account", "Request new password"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["/user/register", "/user/password"].include?(node['href']) &&
Set["Create a new user account.", "Request new password via e-mail."].include?(node['title']) &&
        true
      end
    end
    class Element_118 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\.item\-list\ >\ ul\ >\ li$/

      def valid? # Rules count: 9
        Set[92, 99].include?(to_html.size) &&
        Set["<li><a href=\"/user/register\" title=\"Create a new user account.\">Create new account</a></li>\n", "<li><a href=\"/user/password\" title=\"Request new password via e-mail.\">Request new password</a></li>"].include?(to_html) &&
        Set[18, 20].include?(text.to_s.size) &&
        Set["Create new account", "Request new password"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["a"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        
        true
      end
    end
    class Element_119 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\.item\-list\ >\ ul$/

      def valid? # Rules count: 9
        202 === to_html.size &&
        "<ul>\n<li><a href=\"/user/register\" title=\"Create a new user account.\">Create new account</a></li>\n<li><a href=\"/user/password\" title=\"Request new password via e-mail.\">Request new password</a></li>\n</ul>" === to_html &&
        38 === text.to_s.size &&
        "Create new accountRequest new password" === text.to_s &&
        2 === children.count &&
        (children_tags - ["li", "li"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        
        true
      end
    end
    class Element_120 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ div\.item\-list$/

      def valid? # Rules count: 9
        232 === to_html.size &&
        "<div class=\"item-list\"><ul>\n<li><a href=\"/user/register\" title=\"Create a new user account.\">Create new account</a></li>\n<li><a href=\"/user/password\" title=\"Request new password via e-mail.\">Request new password</a></li>\n</ul></div>\n" === to_html &&
        38 === text.to_s.size &&
        "Create new accountRequest new password" === text.to_s &&
        1 === children.count &&
        (children_tags - ["ul"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "item-list" === node['class'] &&
        true
      end
    end
    class Element_121 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div\ >\ input\#edit\-user\-login\-block$/

      def valid? # Rules count: 9
        88 === to_html.size &&
        "<input type=\"hidden\" name=\"form_id\" id=\"edit-user-login-block\" value=\"user_login_block\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "hidden" === node['type'] &&
"form_id" === node['name'] &&
"edit-user-login-block" === node['id'] &&
"user_login_block" === node['value'] &&
        true
      end
    end
    class Element_122 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form\ >\ div$/

      def valid? # Rules count: 9
        959 === to_html.size &&
        "<div>\n<div class=\"form-item\" id=\"edit-name-wrapper\">\n <label for=\"edit-name\">Username: <span class=\"form-required\" title=\"This field is required.\">*</span></label>\n <input type=\"text\" maxlength=\"60\" name=\"name\" id=\"edit-name\" size=\"15\" value=\"\" class=\"form-text required\">\n</div>\n<div class=\"form-item\" id=\"edit-pass-wrapper\">\n <label for=\"edit-pass\">Password: <span class=\"form-required\" title=\"This field is required.\">*</span></label>\n <input type=\"password\" name=\"pass\" id=\"edit-pass\" maxlength=\"60\" size=\"15\" class=\"form-text required\">\n</div>\n<input type=\"submit\" name=\"op\" id=\"edit-submit\" value=\"Log in\" class=\"form-submit\"><div class=\"item-list\"><ul>\n<li><a href=\"/user/register\" title=\"Create a new user account.\">Create new account</a></li>\n<li><a href=\"/user/password\" title=\"Request new password via e-mail.\">Request new password</a></li>\n</ul></div>\n<input type=\"hidden\" name=\"form_id\" id=\"edit-user-login-block\" value=\"user_login_block\">\n</div>" === to_html &&
        70 === text.to_s.size &&
        "\n Username: *\n \n\n Password: *\n \nCreate new accountRequest new password" === text.to_s &&
        7 === children.count &&
        (children_tags - ["div", "text", "div", "text", "input", "div", "input"] == []) &&
        (children_classes - ["form-item", nil, "form-item", nil, "form-submit", "item-list", nil] == []) &&
        (children_ids - ["edit-name-wrapper", nil, "edit-pass-wrapper", nil, "edit-submit", nil, "edit-user-login-block"] == []) &&
        
        true
      end
    end
    class Element_123 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-user\ >\ div\.content\ >\ form\#user\-login\-form$/

      def valid? # Rules count: 9
        (1080..1145) === to_html.size &&
        /^<form\ action="\/tipitaka\/.*"\ accept\-charset="UTF\-8"\ method="post"\ id="user\-login\-form">\n<div>\n<div\ class="form\-item"\ id="edit\-name\-wrapper">\n\ <label\ for="edit\-name">Username:\ <span\ class="form\-required"\ title="This\ field\ is\ required\.">\*<\/span><\/label>\n\ <input\ type="text"\ maxlength="60"\ name="name"\ id="edit\-name"\ size="15"\ value=""\ class="form\-text\ required">\n<\/div>\n<div\ class="form\-item"\ id="edit\-pass\-wrapper">\n\ <label\ for="edit\-pass">Password:\ <span\ class="form\-required"\ title="This\ field\ is\ required\.">\*<\/span><\/label>\n\ <input\ type="password"\ name="pass"\ id="edit\-pass"\ maxlength="60"\ size="15"\ class="form\-text\ required">\n<\/div>\n<input\ type="submit"\ name="op"\ id="edit\-submit"\ value="Log\ in"\ class="form\-submit"><div\ class="item\-list"><ul>\n<li><a\ href="\/user\/register"\ title="Create\ a\ new\ user\ account\.">Create\ new\ account<\/a><\/li>\n<li><a\ href="\/user\/password"\ title="Request\ new\ password\ via\ e\-mail\.">Request\ new\ password<\/a><\/li>\n<\/ul><\/div>\n<input\ type="hidden"\ name="form_id"\ id="edit\-user\-login\-block"\ value="user_login_block">\n<\/div>\n<\/form>$/m === to_html &&
        71 === text.to_s.size &&
        "\n\n Username: *\n \n\n Password: *\n \nCreate new accountRequest new password" === text.to_s &&
        2 === children.count &&
        (children_tags - ["text", "div"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        /^\/tipitaka\/.*$/m === node['action'] &&
"UTF-8" === node['accept-charset'] &&
"post" === node['method'] &&
"user-login-form" === node['id'] &&
        true
      end
    end
    class Element_124 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div$/

      def valid? # Rules count: 9
        (10006..36892) === to_html.size &&
        /^<div\ id="sidebar\-left\-div">\ \ <div\ class="block\ block\-tipitaka"\ id="block\-tipitaka\-0">\n\ \ \ \ <h2\ class="title">.*"\ accept\-charset="UTF\-8"\ method="post"\ id="user\-login\-form">\n<div>\n<div\ class="form\-item"\ id="edit\-name\-wrapper">\n\ <label\ for="edit\-name">Username:\ <span\ class="form\-required"\ title="This\ field\ is\ required\.">\*<\/span><\/label>\n\ <input\ type="text"\ maxlength="60"\ name="name"\ id="edit\-name"\ size="15"\ value=""\ class="form\-text\ required">\n<\/div>\n<div\ class="form\-item"\ id="edit\-pass\-wrapper">\n\ <label\ for="edit\-pass">Password:\ <span\ class="form\-required"\ title="This\ field\ is\ required\.">\*<\/span><\/label>\n\ <input\ type="password"\ name="pass"\ id="edit\-pass"\ maxlength="60"\ size="15"\ class="form\-text\ required">\n<\/div>\n<input\ type="submit"\ name="op"\ id="edit\-submit"\ value="Log\ in"\ class="form\-submit"><div\ class="item\-list"><ul>\n<li><a\ href="\/user\/register"\ title="Create\ a\ new\ user\ account\.">Create\ new\ account<\/a><\/li>\n<li><a\ href="\/user\/password"\ title="Request\ new\ password\ via\ e\-mail\.">Request\ new\ password<\/a><\/li>\n<\/ul><\/div>\n<input\ type="hidden"\ name="form_id"\ id="edit\-user\-login\-block"\ value="user_login_block">\n<\/div>\n<\/form>\n<\/div>\n\ <\/div>\n<\/div>$/m === to_html &&
        (1328..4532) === text.to_s.size &&
        /^\ \ \n\ \ \ \ .*\n\ \n\ \ \n\ \ \ \ World\ Tipi\u1E6Daka\ Edition\ 40\ Vols\n\ \ \ \ \n\n\n\n\t\t\t\tView\n\t\t\t\t\n\n\t\t\t\tTitle:\ P\u0101\u1E37i\ Sound\ Order\n\t\t\t\t\n\n\t\t\t\tTitle:\ Roman\-alphabet\ Order\n\t\t\t\t\n\n\t\t\t\tTitle:\ Tipi\u1E6Daka\ Structure\n\t\t\t\t\n\n\n\n\ \n\ \ \n\ \ \ \ Chulachomklao\ of\ Siam\ P\u0101\u1E37i\ Tipi\u1E6Daka\n\ \ \ \ \n\n\n\n\t\t\t\tSearch\ Siam\/Roman\ script\n\t\t\t\t\n\n\t\t\t\tTipi\u1E6Daka\ Archive\n\t\t\t\t\n\n\t\t\t\tDigital\ Preservation\n\t\t\t\t\nTipi\u1E6Daka\ Documentary\n\n\n\n\ \n\ \ \n\ \ \ \ Tipi\u1E6Daka\ Studies\ Reference\ Database\n\ \ \ \ \n\n\n\n\t\t\t\tSearch\ Tipi\u1E6Daka\ Corpus\n\t\t\t\t\n\n\t\t\t\tNotes\ &\ References\n\t\t\t\t\n\n\t\t\t\tTechnical\ P\u0101\u1E37i\ Terms\n\t\t\t\t\nTranslation\ Index\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \nSubject\ Index\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \n\n\n\n\ \n\ \ \n\ \ \ \ World\ Tipi\u1E6Daka\ P\u0101\u1E37i\ Recitation\n\ \ \ \ \u00A0\n\n\n\u00A0P\u0101timokkha\ Recitation\n\n\n\n\u00A0P\u0101\u1E37i\ Recitation\ Dictionary\n\n\n\n\u00A0International\ Phonetic\ Alphabet\ P\u0101\u1E37i\n\n\n\n\u00A0Tipi\u1E6Daka\ Recitation\n\n\n\ \n\ \ \n\ \ \ \ Quick\ View\n\ \ \ \ \n\n\ 1V2V3V4V5V6D7D8D9M10M11M12S112S213S313S414S515A115A215A315A416A516A616A717A817A917A1017A1118Kh18Dh18Ud18It18Sn19Vv19Pv19Th119Th220Ap120Ap221Bu21Cp22J23J24Mn25Cn26Ps27Ne27Pe28Mi29Dhs30Vbh31Dht31Pu32Kv33Y133Y233Y333Y433Y534Y634Y734Y835Y935Y1036P137P138P239P339P439P539P640P740P840P940P1040P1140P1240P1340P1440P1540P1640P1740P1840P1940P2040P2140P2240P2340P24\n\n\ e\.g\.\ 100\n\n\n\n\ \n\ \ \n\ \ \ \ Navigation\n\ \ \ \ \nAudio\n\n\n\ \n\ \ \n\ \ \ \ User\ login\n\ \ \ \ \n\n\ Username:\ \*\n\ \n\n\ Password:\ \*\n\ \nCreate\ new\ accountRequest\ new\ password\n\n\ \n$/m === text.to_s &&
        17 === children.count &&
        (children_tags - ["text", "div", "text", "div", "text", "div", "text", "div", "text", "div", "text", "div", "text", "div", "text", "div", "text"] == []) &&
        (children_classes - [nil, "block block-tipitaka", nil, "block block-block", nil, "block block-block", nil, "block block-block", nil, "block block-block", nil, "block block-tipitaka", nil, "block block-user", nil, "block block-user", nil] == []) &&
        (children_ids - [nil, "block-tipitaka-0", nil, "block-block-7", nil, "block-block-13", nil, "block-block-6", nil, "block-block-4", nil, "block-tipitaka-2", nil, "block-user-1", nil, "block-user-0", nil] == []) &&
        "sidebar-left-div" === node['id'] &&
        true
      end
    end
    class Element_125 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left$/

      def valid? # Rules count: 9
        (10046..36932) === to_html.size &&
        /^<td\ id="sidebar\-left">\n\ \ \ \ \ \ \ <div\ id="sidebar\-left\-div">\ \ <div\ class="block\ block\-tipitaka"\ id="block\-tipitaka\-0">\n\ \ \ \ <h2\ class="title">.*"\ accept\-charset="UTF\-8"\ method="post"\ id="user\-login\-form">\n<div>\n<div\ class="form\-item"\ id="edit\-name\-wrapper">\n\ <label\ for="edit\-name">Username:\ <span\ class="form\-required"\ title="This\ field\ is\ required\.">\*<\/span><\/label>\n\ <input\ type="text"\ maxlength="60"\ name="name"\ id="edit\-name"\ size="15"\ value=""\ class="form\-text\ required">\n<\/div>\n<div\ class="form\-item"\ id="edit\-pass\-wrapper">\n\ <label\ for="edit\-pass">Password:\ <span\ class="form\-required"\ title="This\ field\ is\ required\.">\*<\/span><\/label>\n\ <input\ type="password"\ name="pass"\ id="edit\-pass"\ maxlength="60"\ size="15"\ class="form\-text\ required">\n<\/div>\n<input\ type="submit"\ name="op"\ id="edit\-submit"\ value="Log\ in"\ class="form\-submit"><div\ class="item\-list"><ul>\n<li><a\ href="\/user\/register"\ title="Create\ a\ new\ user\ account\.">Create\ new\ account<\/a><\/li>\n<li><a\ href="\/user\/password"\ title="Request\ new\ password\ via\ e\-mail\.">Request\ new\ password<\/a><\/li>\n<\/ul><\/div>\n<input\ type="hidden"\ name="form_id"\ id="edit\-user\-login\-block"\ value="user_login_block">\n<\/div>\n<\/form>\n<\/div>\n\ <\/div>\n<\/div>\n\ \ \ \ <\/td>$/m === to_html &&
        (1341..4545) === text.to_s.size &&
        /^\n\ \ \ \ \ \ \ \ \ \n\ \ \ \ .*\n\ \n\ \ \n\ \ \ \ World\ Tipi\u1E6Daka\ Edition\ 40\ Vols\n\ \ \ \ \n\n\n\n\t\t\t\tView\n\t\t\t\t\n\n\t\t\t\tTitle:\ P\u0101\u1E37i\ Sound\ Order\n\t\t\t\t\n\n\t\t\t\tTitle:\ Roman\-alphabet\ Order\n\t\t\t\t\n\n\t\t\t\tTitle:\ Tipi\u1E6Daka\ Structure\n\t\t\t\t\n\n\n\n\ \n\ \ \n\ \ \ \ Chulachomklao\ of\ Siam\ P\u0101\u1E37i\ Tipi\u1E6Daka\n\ \ \ \ \n\n\n\n\t\t\t\tSearch\ Siam\/Roman\ script\n\t\t\t\t\n\n\t\t\t\tTipi\u1E6Daka\ Archive\n\t\t\t\t\n\n\t\t\t\tDigital\ Preservation\n\t\t\t\t\nTipi\u1E6Daka\ Documentary\n\n\n\n\ \n\ \ \n\ \ \ \ Tipi\u1E6Daka\ Studies\ Reference\ Database\n\ \ \ \ \n\n\n\n\t\t\t\tSearch\ Tipi\u1E6Daka\ Corpus\n\t\t\t\t\n\n\t\t\t\tNotes\ &\ References\n\t\t\t\t\n\n\t\t\t\tTechnical\ P\u0101\u1E37i\ Terms\n\t\t\t\t\nTranslation\ Index\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \nSubject\ Index\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \n\n\n\n\ \n\ \ \n\ \ \ \ World\ Tipi\u1E6Daka\ P\u0101\u1E37i\ Recitation\n\ \ \ \ \u00A0\n\n\n\u00A0P\u0101timokkha\ Recitation\n\n\n\n\u00A0P\u0101\u1E37i\ Recitation\ Dictionary\n\n\n\n\u00A0International\ Phonetic\ Alphabet\ P\u0101\u1E37i\n\n\n\n\u00A0Tipi\u1E6Daka\ Recitation\n\n\n\ \n\ \ \n\ \ \ \ Quick\ View\n\ \ \ \ \n\n\ 1V2V3V4V5V6D7D8D9M10M11M12S112S213S313S414S515A115A215A315A416A516A616A717A817A917A1017A1118Kh18Dh18Ud18It18Sn19Vv19Pv19Th119Th220Ap120Ap221Bu21Cp22J23J24Mn25Cn26Ps27Ne27Pe28Mi29Dhs30Vbh31Dht31Pu32Kv33Y133Y233Y333Y433Y534Y634Y734Y835Y935Y1036P137P138P239P339P439P539P640P740P840P940P1040P1140P1240P1340P1440P1540P1640P1740P1840P1940P2040P2140P2240P2340P24\n\n\ e\.g\.\ 100\n\n\n\n\ \n\ \ \n\ \ \ \ Navigation\n\ \ \ \ \nAudio\n\n\n\ \n\ \ \n\ \ \ \ User\ login\n\ \ \ \ \n\n\ Username:\ \*\n\ \n\n\ Password:\ \*\n\ \nCreate\ new\ accountRequest\ new\ password\n\n\ \n\n\ \ \ \ $/m === text.to_s &&
        3 === children.count &&
        (children_tags - ["text", "div", "text"] == []) &&
        (children_classes - [nil, nil, nil] == []) &&
        (children_ids - [nil, "sidebar-left-div", nil] == []) &&
        "sidebar-left" === node['id'] &&
        true
      end
    end
    class Element_126 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ text$/

      def valid? # Rules count: 9
        Set[4, 7].include?(to_html.size) &&
        Set["    ", "\n      "].include?(to_html) &&
        Set[4, 7].include?(text.to_s.size) &&
        Set["    ", "\n      "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_127 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ text$/

      def valid? # Rules count: 9
        Set[13, 7, 5].include?(to_html.size) &&
        Set["\n            ", "\n      ", "\n    "].include?(to_html) &&
        Set[13, 7, 5].include?(text.to_s.size) &&
        Set["\n            ", "\n      ", "\n    "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_128 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#statement\ >\ text$/

      def valid? # Rules count: 9
        42 === to_html.size &&
        "Tipiṭaka Studies in Theravāda Buddhasāsana" === to_html &&
        42 === text.to_s.size &&
        "Tipiṭaka Studies in Theravāda Buddhasāsana" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_129 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#statement$/

      def valid? # Rules count: 9
        68 === to_html.size &&
        "<div id=\"statement\">Tipiṭaka Studies in Theravāda Buddhasāsana</div>" === to_html &&
        42 === text.to_s.size &&
        "Tipiṭaka Studies in Theravāda Buddhasāsana" === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "statement" === node['id'] &&
        true
      end
    end
    class Element_130 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ text$/

      def valid? # Rules count: 9
        Set[10, 8, 9, 27, 15].include?(to_html.size) &&
        Set[" \n        ", "        ", "\n        ", "\n                          ", "\n              "].include?(to_html) &&
        Set[10, 8, 9, 27, 15].include?(text.to_s.size) &&
        Set[" \n        ", "        ", "\n        ", "\n                          ", "\n              "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_131 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.breadcrumb\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (4..61) === to_html.size &&
        /^.*$/m === to_html &&
        (4..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_132 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.breadcrumb\ >\ a$/

      def valid? # Rules count: 9
        (20..103) === to_html.size &&
        /^<a\ href="\/.*<\/a>$/m === to_html &&
        (4..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        /^\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_133 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.breadcrumb$/

      def valid? # Rules count: 9
        (50..519) === to_html.size &&
        /^<div\ class="breadcrumb">.*<\/div>$/m === to_html &&
        (4..216) === text.to_s.size &&
        /^Home.*$/m === text.to_s &&
        Set[1, 3, 5, 7, 9, 11, 13].include?(children.count) &&
        Set[["a"], ["a", "text", "a"], ["a", "text", "a", "text", "a"], ["a", "text", "a", "text", "a", "text", "a"], ["a", "text", "a", "text", "a", "text", "a", "text", "a"], ["a", "text", "a", "text", "a", "text", "a", "text", "a", "text", "a"], ["a", "text", "a", "text", "a", "text", "a", "text", "a", "text", "a", "text", "a"]].include?(children_tags) &&
        Set[[nil], [nil, nil, nil], [nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]].include?(children_classes) &&
        Set[[nil], [nil, nil, nil], [nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]].include?(children_ids) &&
        "breadcrumb" === node['class'] &&
        true
      end
    end
    class Element_134 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ h1\.title\ >\ text$/

      def valid? # Rules count: 9
        (4..71) === to_html.size &&
        /^.*$/m === to_html &&
        (4..71) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_135 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ h1\.title$/

      def valid? # Rules count: 9
        (27..94) === to_html.size &&
        /^<h1\ class="title">.*<\/h1>$/m === to_html &&
        (4..71) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "title" === node['class'] &&
        true
      end
    end
    class Element_136 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.tabs$/

      def valid? # Rules count: 9
        24 === to_html.size &&
        "<div class=\"tabs\"></div>" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "tabs" === node['class'] &&
        true
      end
    end
    class Element_137 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ text$/

      def valid? # Rules count: 9
        Set[13, 5, 20, 33].include?(to_html.size) &&
        /^.*\ $/m === to_html &&
        Set[13, 5, 20, 33].include?(text.to_s.size) &&
        /^.*\ $/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_138 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ span\.submitted$/

      def valid? # Rules count: 9
        31 === to_html.size &&
        "<span class=\"submitted\"></span>" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "submitted" === node['class'] &&
        true
      end
    end
    class Element_139 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ span\.taxonomy$/

      def valid? # Rules count: 9
        30 === to_html.size &&
        "<span class=\"taxonomy\"></span>" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "taxonomy" === node['class'] &&
        true
      end
    end
    class Element_140 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\ >\ text$/

      def valid? # Rules count: 9
        Set[7, 4, 10].include?(to_html.size) &&
        Set["Please ", " or ", " to quote."].include?(to_html) &&
        Set[7, 4, 10].include?(text.to_s.size) &&
        Set["Please ", " or ", " to quote."].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_141 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        Set[5, 8].include?(to_html.size) &&
        Set["login", "register"].include?(to_html) &&
        Set[5, 8].include?(text.to_s.size) &&
        Set["login", "register"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_142 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\ >\ a$/

      def valid? # Rules count: 9
        Set[25, 37].include?(to_html.size) &&
        Set["<a href=\"/user\">login</a>", "<a href=\"/user/register\">register</a>"].include?(to_html) &&
        Set[5, 8].include?(text.to_s.size) &&
        Set["login", "register"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["/user", "/user/register"].include?(node['href']) &&
        true
      end
    end
    class Element_143 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div$/

      def valid? # Rules count: 9
        121 === to_html.size &&
        "<div style=\"text-align:right;\">Please <a href=\"/user\">login</a> or <a href=\"/user/register\">register</a> to quote.</div>\n" === to_html &&
        34 === text.to_s.size &&
        "Please login or register to quote." === text.to_s &&
        5 === children.count &&
        (children_tags - ["text", "a", "text", "a", "text"] == []) &&
        (children_classes - [nil, nil, nil, nil, nil] == []) &&
        (children_ids - [nil, nil, nil, nil, nil] == []) &&
        "text-align:right;" === node['style'] &&
        true
      end
    end
    class Element_144 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#ajax_loader\ >\ p\ >\ img$/

      def valid? # Rules count: 9
        65 === to_html.size &&
        "<img src=\"/sites/all/modules/tipitaka/images/content-loader.gif\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/sites/all/modules/tipitaka/images/content-loader.gif" === node['src'] &&
        true
      end
    end
    class Element_145 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#ajax_loader\ >\ p$/

      def valid? # Rules count: 9
        Set[73, 17].include?(to_html.size) &&
        Set["<p><img src=\"/sites/all/modules/tipitaka/images/content-loader.gif\"></p>\n", "<p>Loading...</p>"].include?(to_html) &&
        Set[0, 10].include?(text.to_s.size) &&
        Set["", "Loading..."].include?(text.to_s) &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        
        true
      end
    end
    class Element_146 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#ajax_loader\ >\ p\ >\ text$/

      def valid? # Rules count: 9
        10 === to_html.size &&
        "Loading..." === to_html &&
        10 === text.to_s.size &&
        "Loading..." === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_147 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#ajax_loader$/

      def valid? # Rules count: 9
        121 === to_html.size &&
        "<div id=\"ajax_loader\">\n<p><img src=\"/sites/all/modules/tipitaka/images/content-loader.gif\"></p>\n<p>Loading...</p>\n</div>\n" === to_html &&
        10 === text.to_s.size &&
        "Loading..." === text.to_s &&
        2 === children.count &&
        (children_tags - ["p", "p"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "ajax_loader" === node['id'] &&
        true
      end
    end
    class Element_148 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_149 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ span\.paragraphNum\ >\ text$/

      def valid? # Rules count: 9
        Set[1, 2, 3, 4].include?(to_html.size) &&
        /^.*$/m === to_html &&
        Set[1, 2, 3, 4].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_150 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ span\.paragraphNum$/

      def valid? # Rules count: 9
        Set[35, 36, 37, 38].include?(to_html.size) &&
        /^<span\ class="paragraphNum">.*<\/span>$/m === to_html &&
        Set[1, 2, 3, 4].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "paragraphNum" === node['class'] &&
        true
      end
    end
    class Element_151 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ text$/

      def valid? # Rules count: 9
        (1..4431) === to_html.size &&
        /^.*$/m === to_html &&
        (1..4431) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_152 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph$/

      def valid? # Rules count: 9
        (66..4499) === to_html.size &&
        /^<div\ class="paragraph">.*<\/div>$/m === to_html &&
        (3..4435) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        (1..61) === children.count &&
        (children_tags - ["span", "text", "table"] == []) &&
        (children_classes - ["paragraphNum", nil, "singleColumn", "bold", "smallFont", "italic", "italic"] == []) &&
        (children_ids - [nil] == []) &&
        "paragraph" === node['class'] &&
        true
      end
    end
    class Element_153 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation$/

      def valid? # Rules count: 9
        (153..4582) === to_html.size &&
        /^<div\ xmlns="http:\/\/www\.w3\.org\/1999\/xhtml"\ class="quotation"\ id=".*>\n<\/div>$/m === to_html &&
        (6..4437) === text.to_s.size &&
        /^\n.*\n$/m === text.to_s &&
        Set[3, 5].include?(children.count) &&
        Set[["text", "div", "text"], ["text", "div", "text", "div", "text"], ["text", "h2", "text"]].include?(children_tags) &&
        Set[[nil, "paragraph", nil], [nil, "divNumber", nil, "paragraph", nil], [nil, "paliSectionName", nil]].include?(children_classes) &&
        Set[[nil, nil, nil], [nil, nil, nil, nil, nil]].include?(children_ids) &&
        "http://www.w3.org/1999/xhtml" === node['xmlns'] &&
"quotation" === node['class'] &&
/^.*$/m === node['id'] &&
        true
      end
    end
    class Element_154 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_155 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode$/

      def valid? # Rules count: 9
        (71..214059) === to_html.size &&
        /^<div\ class="tipitakaNode">\n<.*>\n<\/div>$/m === to_html &&
        (31..115532) === text.to_s.size &&
        /^.*\n$/m === text.to_s &&
        (2..1528) === children.count &&
        (children_tags - ["div", "text", "p"] == []) &&
        (children_classes - ["quotation", nil, "hidden", "CENTER", "SUMMARY", "ENDH3", "ENDBOOK"] == []) &&
        "tipitakaNode" === node['class'] &&
        true
      end
    end
    class Element_156 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper$/

      def valid? # Rules count: 9
        (108..214096) === to_html.size &&
        /^<div\ id="tipitakaBodyWrapper"><div\ class="tipitakaNode">\n<.*>\n<\/div><\/div>\n$/m === to_html &&
        (31..115532) === text.to_s.size &&
        /^.*\n$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["div"] == []) &&
        (children_classes - ["tipitakaNode"] == []) &&
        (children_ids - [nil] == []) &&
        "tipitakaBodyWrapper" === node['id'] &&
        true
      end
    end
    class Element_157 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ script\ >\ \#cdata\-section$/

      def valid? # Rules count: 9
        34 === to_html.size &&
        "adjustTipitakaBodyWrapperHeight();" === to_html &&
        34 === text.to_s.size &&
        "adjustTipitakaBodyWrapperHeight();" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_158 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ script$/

      def valid? # Rules count: 9
        74 === to_html.size &&
        "<script type=\"text/javascript\">adjustTipitakaBodyWrapperHeight();</script>" === to_html &&
        34 === text.to_s.size &&
        "adjustTipitakaBodyWrapperHeight();" === text.to_s &&
        1 === children.count &&
        (children_tags - ["#cdata-section"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "text/javascript" === node['type'] &&
        true
      end
    end
    class Element_159 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ ul\.menu\ >\ li\.collapsed\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (5..61) === to_html.size &&
        /^.*$/m === to_html &&
        (5..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_160 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ ul\.menu\ >\ li\.collapsed\ >\ a$/

      def valid? # Rules count: 9
        (50..114) === to_html.size &&
        /^<a\ rel="link"\ href="\/tipitaka\/.*<\/a>$/m === to_html &&
        (5..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "link" === node['rel'] &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_161 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ ul\.menu\ >\ li\.collapsed$/

      def valid? # Rules count: 9
        (113..177) === to_html.size &&
        /^<li\ class="collapsed"\ nid="2.*$/m === to_html &&
        (5..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["a"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "collapsed" === node['class'] &&
(257314..276935) === node['nid'] &&
"tipitaka_ajax_i" === node['rel'] &&
        true
      end
    end
    class Element_162 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ ul\.menu$/

      def valid? # Rules count: 9
        (137..12719) === to_html.size &&
        /^<ul\ class="menu">.*<\/ul>\n$/m === to_html &&
        (5..3106) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        (1..94) === children.count &&
        (children_tags - ["li"] == []) &&
        (children_classes - ["collapsed", "leaf"] == []) &&
        (children_ids - [nil] == []) &&
        "menu" === node['class'] &&
        true
      end
    end
    class Element_163 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ div\.page\-links\ clear\-block\ >\ a\.page\-next\ >\ text$/

      def valid? # Rules count: 9
        (13..80) === to_html.size &&
        /^.*\ &gt;&gt;$/m === to_html &&
        (7..74) === text.to_s.size &&
        /^.*\ >>$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_164 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ div\.page\-links\ clear\-block\ >\ a\.page\-next$/

      def valid? # Rules count: 9
        (125..205) === to_html.size &&
        /^<a\ href="\/tipitaka\/.*\ &gt;&gt;<\/a>$/m === to_html &&
        (7..74) === text.to_s.size &&
        /^.*\ >>$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        /^\/tipitaka\/.*$/m === node['href'] &&
(257314..277392) === node['nid'] &&
"tipitaka_ajax_i" === node['rel'] &&
"page-next" === node['class'] &&
"Go to next page" === node['title'] &&
        true
      end
    end
    class Element_165 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ div\.page\-links\ clear\-block$/

      def valid? # Rules count: 9
        (167..586) === to_html.size &&
        /^<div\ class="page\-links\ clear\-block">.*<\/div>$/m === to_html &&
        (10..113) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        Set[1, 3, 2].include?(children.count) &&
        Set[["a"], ["a", "a", "a"], ["a", "a"]].include?(children_tags) &&
        Set[["page-next"], ["page-previous", "page-up", "page-next"], ["page-previous", "page-up"]].include?(children_classes) &&
        Set[[nil], [nil, nil, nil], [nil, nil]].include?(children_ids) &&
        "page-links clear-block" === node['class'] &&
        true
      end
    end
    class Element_166 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation$/

      def valid? # Rules count: 9
        (332..12943) === to_html.size &&
        /^<div\ class="tipitaka\-navigation">.*<\/div>$/m === to_html &&
        (10..3132) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        Set[2, 1].include?(children.count) &&
        Set[["ul", "div"], ["div"]].include?(children_tags) &&
        Set[["menu", "page-links clear-block"], ["page-links clear-block"]].include?(children_classes) &&
        Set[[nil, nil], [nil]].include?(children_ids) &&
        "tipitaka-navigation" === node['class'] &&
        true
      end
    end
    class Element_167 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content$/

      def valid? # Rules count: 9
        (804..214773) === to_html.size &&
        /^<div\ class="content">\n<div\ style="text\-align:right;">Please\ <a\ href="\/user">login<\/a>\ or\ <a\ href="\/user\/register">register<\/a>\ to\ quote\.<\/div>\n<div\ id="ajax_loader">\n<p><img\ src="\/sites\/all\/modules\/tipitaka\/images\/content\-loader\.gif"><\/p>\n<p>Loading\.\.\.<\/p>\n<\/div>\n<div\ id="tipitakaBodyWrapper"><div\ class="tipitakaNode">\n<.*<\/div>\n<\/div>$/m === to_html &&
        (127..115655) === text.to_s.size &&
        /^Please\ login\ or\ register\ to\ quote\.Loading\.\.\..*$/m === text.to_s &&
        5 === children.count &&
        (children_tags - ["div", "div", "div", "script", "div"] == []) &&
        (children_classes - [nil, nil, nil, nil, "tipitaka-navigation"] == []) &&
        (children_ids - [nil, "ajax_loader", "tipitakaBodyWrapper", nil, nil] == []) &&
        "content" === node['class'] &&
        true
      end
    end
    class Element_168 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        Set[12, 6, 7].include?(to_html.size) &&
        Set["tipitakahall", "orawan", "sarawut"].include?(to_html) &&
        Set[12, 6, 7].include?(text.to_s.size) &&
        Set["tipitakahall", "orawan", "sarawut"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_169 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ a$/

      def valid? # Rules count: 9
        Set[33, 27, 28].include?(to_html.size) &&
        Set["<a href=\"user/1\">tipitakahall</a>", "<a href=\"user/3\">orawan</a>", "<a href=\"user/4\">sarawut</a>"].include?(to_html) &&
        Set[12, 6, 7].include?(text.to_s.size) &&
        Set["tipitakahall", "orawan", "sarawut"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["user/1", "user/3", "user/4"].include?(node['href']) &&
        true
      end
    end
    class Element_170 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node$/

      def valid? # Rules count: 9
        (998..214967) === to_html.size &&
        /^<div\ class="node">\n\ \ \ \ \ \ \ \ \ \ \ \ <span\ class="submitted"><\/span>\n\ \ \ \ <span\ class="taxonomy"><\/span>\n\ \ \ \ <div\ class="content">\n<div\ style="text\-align:right;">Please\ <a\ href="\/user">login<\/a>\ or\ <a\ href="\/user\/register">register<\/a>\ to\ quote\.<\/div>\n<div\ id="ajax_loader">\n<p><img\ src="\/sites\/all\/modules\/tipitaka\/images\/content\-loader\.gif"><\/p>\n<p>Loading\.\.\.<\/p>\n<\/div>\n<div\ id="tipitakaBodyWrapper"><div\ class="tipitakaNode">\n<.*\ \ \ \ \ \ <\/div>$/m === to_html &&
        (215..115743) === text.to_s.size &&
        /^\n\ \ \ \ \ \ \ \ \ \ \ \ \n\ \ \ \ \n\ \ \ \ Please\ login\ or\ register\ to\ quote\.Loading\.\.\..*\ \ \ \ \ \ $/m === text.to_s &&
        9 === children.count &&
        (children_tags - ["text", "span", "text", "span", "text", "div", "text", "a", "text"] == []) &&
        (children_classes - [nil, "submitted", nil, "taxonomy", nil, "content", nil, nil, nil] == []) &&
        (children_ids - [nil, nil, nil, nil, nil, nil, nil, nil, nil] == []) &&
        "node" === node['class'] &&
        true
      end
    end
    class Element_171 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main$/

      def valid? # Rules count: 9
        (1200..215218) === to_html.size &&
        /^<div\ id="main">\ \n\ \ \ \ \ \ \ \ <div\ class="breadcrumb">.*\ \ \ \ \ \ <\/div>\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ <\/div>$/m === to_html &&
        (316..115881) === text.to_s.size &&
        /^\ \n\ \ \ \ \ \ \ \ Home\ .*\ \ \ \ \ \ \n\ \ \ \ \ \ \ \ \ \ \ \ \ \ $/m === text.to_s &&
        9 === children.count &&
        (children_tags - ["text", "div", "text", "h1", "text", "div", "text", "div", "text"] == []) &&
        (children_classes - [nil, "breadcrumb", nil, "title", nil, "tabs", nil, "node", nil] == []) &&
        (children_ids - [nil, nil, nil, nil, nil, nil, nil, nil, nil] == []) &&
        "main" === node['id'] &&
        true
      end
    end
    class Element_172 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main$/

      def valid? # Rules count: 9
        (1331..215349) === to_html.size &&
        /^<td\ valign="top"\ id="table\-main">\n\ \ \ \ \ \ \ \ \ \ \ \ <div\ id="statement">Tipi\u1E6Daka\ Studies\ in\ Therav\u0101da\ Buddhas\u0101sana<\/div>\n\ \ \ \ \ \ <div\ id="main">\ \n\ \ \ \ \ \ \ \ <div\ class="breadcrumb">.*\ \ \ \ \ \ <\/div>\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ <\/div>\n\ \ \ \ <\/td>$/m === to_html &&
        (383..115948) === text.to_s.size &&
        /^\n\ \ \ \ \ \ \ \ \ \ \ \ Tipiṭaka\ Studies\ in\ Theravāda\ Buddhasāsana\n\ \ \ \ \ \ \ \n\ \ \ \ \ \ \ \ Home\ .*\ \ \ \ \ \ \n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \n\ \ \ \ $/m === text.to_s &&
        5 === children.count &&
        (children_tags - ["text", "div", "text", "div", "text"] == []) &&
        (children_classes - [nil, nil, nil, nil, nil] == []) &&
        (children_ids - [nil, "statement", nil, "main", nil] == []) &&
        "top" === node['valign'] &&
"table-main" === node['id'] &&
        true
      end
    end
    class Element_173 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr$/

      def valid? # Rules count: 9
        (11398..226377) === to_html.size &&
        /^<tr>\n<td\ id="sidebar\-left">\n\ \ \ \ \ \ \ <div\ id="sidebar\-left\-div">\ \ <div\ class="block\ block\-tipitaka"\ id="block\-tipitaka\-0">\n\ \ \ \ <h2\ class="title">.*\ \ \ \ \ \ <\/div>\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ <\/div>\n\ \ \ \ <\/td>\n\ \ \ \ \ \ <\/tr>$/m === to_html &&
        (1735..117531) === text.to_s.size &&
        /^\n\ \ \ \ \ \ \ \ \ \n\ \ \ \ .*\ \ \ \ \ \ \n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \n\ \ \ \ \n\ \ \ \ \ \ $/m === text.to_s &&
        4 === children.count &&
        (children_tags - ["td", "text", "td", "text"] == []) &&
        (children_classes - [nil, nil, nil, nil] == []) &&
        (children_ids - ["sidebar-left", nil, "table-main", nil] == []) &&
        
        true
      end
    end
    class Element_174 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content$/

      def valid? # Rules count: 9
        (11470..226449) === to_html.size &&
        /^<table\ border="0"\ cellpadding="0"\ cellspacing="0"\ id="content"><tr>\n<td\ id="sidebar\-left">\n\ \ \ \ \ \ \ <div\ id="sidebar\-left\-div">\ \ <div\ class="block\ block\-tipitaka"\ id="block\-tipitaka\-0">\n\ \ \ \ <h2\ class="title">.*\ \ \ \ \ \ <\/div>\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ <\/div>\n\ \ \ \ <\/td>\n\ \ \ \ \ \ <\/tr><\/table>\n$/m === to_html &&
        (1735..117531) === text.to_s.size &&
        /^\n\ \ \ \ \ \ \ \ \ \n\ \ \ \ .*\ \ \ \ \ \ \n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \n\ \ \ \ \n\ \ \ \ \ \ $/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["tr"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        0 === node['border'] &&
0 === node['cellpadding'] &&
0 === node['cellspacing'] &&
"content" === node['id'] &&
        true
      end
    end
    class Element_175 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ div\#footer\ >\ text$/

      def valid? # Rules count: 9
        Set[6, 3, 1].include?(to_html.size) &&
        Set["\n  \n  ", "\n  ", "\n"].include?(to_html) &&
        Set[6, 3, 1].include?(text.to_s.size) &&
        Set["\n  \n  ", "\n  ", "\n"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_176 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ div\#footer\ >\ div\.block\ block\-block\ >\ text$/

      def valid? # Rules count: 9
        Set[5, 2].include?(to_html.size) &&
        Set["\n    ", "\n "].include?(to_html) &&
        Set[5, 2].include?(text.to_s.size) &&
        Set["\n    ", "\n "].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_177 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ div\#footer\ >\ div\.block\ block\-block\ >\ h2\.title$/

      def valid? # Rules count: 9
        23 === to_html.size &&
        "<h2 class=\"title\"></h2>" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "title" === node['class'] &&
        true
      end
    end
    class Element_178 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ div\#footer\ >\ div\.block\ block\-block\ >\ div\.content\ >\ text$/

      def valid? # Rules count: 9
        99 === to_html.size &&
        "Copyright © 2005 - 2012 Dhamma Society - dhammasociety.org. email : worldtipitaka@dhammasociety.org" === to_html &&
        99 === text.to_s.size &&
        "Copyright © 2005 - 2012 Dhamma Society - dhammasociety.org. email : worldtipitaka@dhammasociety.org" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_179 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ div\#footer\ >\ div\.block\ block\-block\ >\ div\.content$/

      def valid? # Rules count: 9
        Set[126, 434].include?(to_html.size) &&
        Set["<div class=\"content\">Copyright © 2005 - 2012 Dhamma Society - dhammasociety.org. email : worldtipitaka@dhammasociety.org</div>", "<div class=\"content\">\n<script type=\"text/javascript\">\nvar gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");\ndocument.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));\n</script><script type=\"text/javascript\">\ntry {\nvar pageTracker = _gat._getTracker(\"UA-2238398-7\");\npageTracker._trackPageview();\n} catch(err) {}\n</script>\n</div>"].include?(to_html) &&
        Set[99, 325].include?(text.to_s.size) &&
        Set["Copyright © 2005 - 2012 Dhamma Society - dhammasociety.org. email : worldtipitaka@dhammasociety.org", "\nvar gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");\ndocument.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));\n\ntry {\nvar pageTracker = _gat._getTracker(\"UA-2238398-7\");\npageTracker._trackPageview();\n} catch(err) {}\n"].include?(text.to_s) &&
        Set[1, 2].include?(children.count) &&
        Set[["text"], ["script", "script"]].include?(children_tags) &&
        Set[[nil], [nil, nil]].include?(children_classes) &&
        Set[[nil], [nil, nil]].include?(children_ids) &&
        "content" === node['class'] &&
        true
      end
    end
    class Element_180 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ div\#footer\ >\ div\.block\ block\-block$/

      def valid? # Rules count: 9
        Set[217, 525].include?(to_html.size) &&
        Set["<div class=\"block block-block\" id=\"block-block-3\">\n    <h2 class=\"title\"></h2>\n    <div class=\"content\">Copyright © 2005 - 2012 Dhamma Society - dhammasociety.org. email : worldtipitaka@dhammasociety.org</div>\n </div>", "<div class=\"block block-block\" id=\"block-block-2\">\n    <h2 class=\"title\"></h2>\n    <div class=\"content\">\n<script type=\"text/javascript\">\nvar gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");\ndocument.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));\n</script><script type=\"text/javascript\">\ntry {\nvar pageTracker = _gat._getTracker(\"UA-2238398-7\");\npageTracker._trackPageview();\n} catch(err) {}\n</script>\n</div>\n </div>"].include?(to_html) &&
        Set[111, 337].include?(text.to_s.size) &&
        Set["\n    \n    Copyright © 2005 - 2012 Dhamma Society - dhammasociety.org. email : worldtipitaka@dhammasociety.org\n ", "\n    \n    \nvar gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");\ndocument.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));\n\ntry {\nvar pageTracker = _gat._getTracker(\"UA-2238398-7\");\npageTracker._trackPageview();\n} catch(err) {}\n\n "].include?(text.to_s) &&
        5 === children.count &&
        (children_tags - ["text", "h2", "text", "div", "text"] == []) &&
        (children_classes - [nil, "title", nil, "content", nil] == []) &&
        (children_ids - [nil, nil, nil, nil, nil] == []) &&
        "block block-block" === node['class'] &&
Set["block-block-3", "block-block-2"].include?(node['id']) &&
        true
      end
    end
    class Element_181 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ div\#footer\ >\ div\.block\ block\-block\ >\ div\.content\ >\ script\ >\ \#cdata\-section$/

      def valid? # Rules count: 9
        Set[220, 105].include?(to_html.size) &&
        Set["\nvar gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");\ndocument.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));\n", "\ntry {\nvar pageTracker = _gat._getTracker(\"UA-2238398-7\");\npageTracker._trackPageview();\n} catch(err) {}\n"].include?(to_html) &&
        Set[220, 105].include?(text.to_s.size) &&
        Set["\nvar gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");\ndocument.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));\n", "\ntry {\nvar pageTracker = _gat._getTracker(\"UA-2238398-7\");\npageTracker._trackPageview();\n} catch(err) {}\n"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_182 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ div\#footer\ >\ div\.block\ block\-block\ >\ div\.content\ >\ script$/

      def valid? # Rules count: 9
        Set[260, 145].include?(to_html.size) &&
        Set["<script type=\"text/javascript\">\nvar gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");\ndocument.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));\n</script>", "<script type=\"text/javascript\">\ntry {\nvar pageTracker = _gat._getTracker(\"UA-2238398-7\");\npageTracker._trackPageview();\n} catch(err) {}\n</script>"].include?(to_html) &&
        Set[220, 105].include?(text.to_s.size) &&
        Set["\nvar gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");\ndocument.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));\n", "\ntry {\nvar pageTracker = _gat._getTracker(\"UA-2238398-7\");\npageTracker._trackPageview();\n} catch(err) {}\n"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["#cdata-section"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "text/javascript" === node['type'] &&
        true
      end
    end
    class Element_183 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ div\#footer$/

      def valid? # Rules count: 9
        775 === to_html.size &&
        "<div id=\"footer\">\n  \n  <div class=\"block block-block\" id=\"block-block-3\">\n    <h2 class=\"title\"></h2>\n    <div class=\"content\">Copyright © 2005 - 2012 Dhamma Society - dhammasociety.org. email : worldtipitaka@dhammasociety.org</div>\n </div>\n  <div class=\"block block-block\" id=\"block-block-2\">\n    <h2 class=\"title\"></h2>\n    <div class=\"content\">\n<script type=\"text/javascript\">\nvar gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");\ndocument.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));\n</script><script type=\"text/javascript\">\ntry {\nvar pageTracker = _gat._getTracker(\"UA-2238398-7\");\npageTracker._trackPageview();\n} catch(err) {}\n</script>\n</div>\n </div>\n</div>" === to_html &&
        458 === text.to_s.size &&
        "\n  \n  \n    \n    Copyright © 2005 - 2012 Dhamma Society - dhammasociety.org. email : worldtipitaka@dhammasociety.org\n \n  \n    \n    \nvar gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");\ndocument.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));\n\ntry {\nvar pageTracker = _gat._getTracker(\"UA-2238398-7\");\npageTracker._trackPageview();\n} catch(err) {}\n\n \n" === text.to_s &&
        5 === children.count &&
        (children_tags - ["text", "div", "text", "div", "text"] == []) &&
        (children_classes - [nil, "block block-block", nil, "block block-block", nil] == []) &&
        (children_ids - [nil, "block-block-3", nil, "block-block-2", nil] == []) &&
        "footer" === node['id'] &&
        true
      end
    end
    class Element_184 < Base
      MATCH = /^document\ >\ html\ >\ body$/

      def valid? # Rules count: 9
        (13156..228139) === to_html.size &&
        /^<body>\n\n<table\ border="0"\ cellpadding="1"\ cellspacing="0"\ id="header">\n<tr>\n<td\ id="logo">\n\ \ \ \ \ \ <a\ href="\/"\ title="Home"><img\ src="\/files\/founder3_logo\.gif"\ alt="Home"><\/a>\ \ \ \ \ \ \n\ \ \ \ <\/td>\n\ \ \ \ <td\ id="menu">\n\ \ \ \ \ \ \ \ \ \ \ \ <div\ style="display:none"\ action="\/tipitaka\/.*\ \ \ \ \ \ <\/div>\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ <\/div>\n\ \ \ \ <\/td>\n\ \ \ \ \ \ <\/tr><\/table>\n<div\ id="footer">\n\ \ \n\ \ <div\ class="block\ block\-block"\ id="block\-block\-3">\n\ \ \ \ <h2\ class="title"><\/h2>\n\ \ \ \ <div\ class="content">Copyright\ \u00A9\ 2005\ \-\ 2012\ Dhamma\ Society\ \-\ dhammasociety\.org\.\ email\ :\ worldtipitaka@dhammasociety\.org<\/div>\n\ <\/div>\n\ \ <div\ class="block\ block\-block"\ id="block\-block\-2">\n\ \ \ \ <h2\ class="title"><\/h2>\n\ \ \ \ <div\ class="content">\n<script\ type="text\/javascript">\nvar\ gaJsHost\ =\ \(\("https:"\ ==\ document\.location\.protocol\)\ \?\ "https:\/\/ssl\."\ :\ "http:\/\/www\."\);\ndocument\.write\(unescape\("%3Cscript\ src='"\ \+\ gaJsHost\ \+\ "google\-analytics\.com\/ga\.js'\ type='text\/javascript'%3E%3C\/script%3E"\)\);\n<\/script><script\ type="text\/javascript">\ntry\ \{\nvar\ pageTracker\ =\ _gat\._getTracker\("UA\-2238398\-7"\);\npageTracker\._trackPageview\(\);\n\}\ catch\(err\)\ \{\}\n<\/script>\n<\/div>\n\ <\/div>\n<\/div>\n<\/body>$/m === to_html &&
        (2248..118044) === text.to_s.size &&
        /^\n\n\n\ \ \ \ \ \ \ \ \ \ \ \ \n\ \ \ \ \n\ \ \ \ \n\ \ \ \ \ \ \ \ \ \ \ \ \n\n\ \n\n\n\ \ \ \ \n\ \ \n\ \ \n\ \ \ \ \ \ \ \ \ \n\ \ \ \ .*\ \ \ \ \ \ \n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \n\ \ \ \ \n\ \ \ \ \ \ \n\ \ \n\ \ \n\ \ \ \ \n\ \ \ \ Copyright\ \u00A9\ 2005\ \-\ 2012\ Dhamma\ Society\ \-\ dhammasociety\.org\.\ email\ :\ worldtipitaka@dhammasociety\.org\n\ \n\ \ \n\ \ \ \ \n\ \ \ \ \nvar\ gaJsHost\ =\ \(\("https:"\ ==\ document\.location\.protocol\)\ \?\ "https:\/\/ssl\."\ :\ "http:\/\/www\."\);\ndocument\.write\(unescape\("%3Cscript\ src='"\ \+\ gaJsHost\ \+\ "google\-analytics\.com\/ga\.js'\ type='text\/javascript'%3E%3C\/script%3E"\)\);\n\ntry\ \{\nvar\ pageTracker\ =\ _gat\._getTracker\("UA\-2238398\-7"\);\npageTracker\._trackPageview\(\);\n\}\ catch\(err\)\ \{\}\n\n\ \n\n$/m === text.to_s &&
        5 === children.count &&
        (children_tags - ["text", "table", "table", "div", "text"] == []) &&
        (children_classes - [nil, nil, nil, nil, nil] == []) &&
        (children_ids - [nil, "header", "content", "footer", nil] == []) &&
        
        true
      end
    end
    class Element_185 < Base
      MATCH = /^document\ >\ html$/

      def valid? # Rules count: 9
        (15818..230842) === to_html.size &&
        /^<html\ xmlns="http:\/\/www\.w3\.org\/1999\/xhtml"\ lang="en"\ xml:lang="en">\n<head>\n<title>.*\ \ \ \ \ \ <\/div>\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ <\/div>\n\ \ \ \ <\/td>\n\ \ \ \ \ \ <\/tr><\/table>\n<div\ id="footer">\n\ \ \n\ \ <div\ class="block\ block\-block"\ id="block\-block\-3">\n\ \ \ \ <h2\ class="title"><\/h2>\n\ \ \ \ <div\ class="content">Copyright\ \u00A9\ 2005\ \-\ 2012\ Dhamma\ Society\ \-\ dhammasociety\.org\.\ email\ :\ worldtipitaka@dhammasociety\.org<\/div>\n\ <\/div>\n\ \ <div\ class="block\ block\-block"\ id="block\-block\-2">\n\ \ \ \ <h2\ class="title"><\/h2>\n\ \ \ \ <div\ class="content">\n<script\ type="text\/javascript">\nvar\ gaJsHost\ =\ \(\("https:"\ ==\ document\.location\.protocol\)\ \?\ "https:\/\/ssl\."\ :\ "http:\/\/www\."\);\ndocument\.write\(unescape\("%3Cscript\ src='"\ \+\ gaJsHost\ \+\ "google\-analytics\.com\/ga\.js'\ type='text\/javascript'%3E%3C\/script%3E"\)\);\n<\/script><script\ type="text\/javascript">\ntry\ \{\nvar\ pageTracker\ =\ _gat\._getTracker\("UA\-2238398\-7"\);\npageTracker\._trackPageview\(\);\n\}\ catch\(err\)\ \{\}\n<\/script>\n<\/div>\n\ <\/div>\n<\/div>\n<\/body>\n<\/html>$/m === to_html &&
        (3134..118935) === text.to_s.size &&
        /^.*\ \ \ \ \ \ \n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \n\ \ \ \ \n\ \ \ \ \ \ \n\ \ \n\ \ \n\ \ \ \ \n\ \ \ \ Copyright\ \u00A9\ 2005\ \-\ 2012\ Dhamma\ Society\ \-\ dhammasociety\.org\.\ email\ :\ worldtipitaka@dhammasociety\.org\n\ \n\ \ \n\ \ \ \ \n\ \ \ \ \nvar\ gaJsHost\ =\ \(\("https:"\ ==\ document\.location\.protocol\)\ \?\ "https:\/\/ssl\."\ :\ "http:\/\/www\."\);\ndocument\.write\(unescape\("%3Cscript\ src='"\ \+\ gaJsHost\ \+\ "google\-analytics\.com\/ga\.js'\ type='text\/javascript'%3E%3C\/script%3E"\)\);\n\ntry\ \{\nvar\ pageTracker\ =\ _gat\._getTracker\("UA\-2238398\-7"\);\npageTracker\._trackPageview\(\);\n\}\ catch\(err\)\ \{\}\n\n\ \n\n$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["head", "body"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "http://www.w3.org/1999/xhtml" === node['xmlns'] &&
"en" === node['lang'] &&
"en" === node['xml:lang'] &&
        true
      end
    end
    class Element_186 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        35 === to_html.size &&
        "<img src=\"/misc/menu-expanded.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-expanded.png" === node['src'] &&
        true
      end
    end
    class Element_187 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ a$/

      def valid? # Rules count: 9
        (50..85) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..43) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_188 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (8..43) === to_html.size &&
        /^.*$/m === to_html &&
        (8..43) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_189 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        31 === to_html.size &&
        "<img src=\"/misc/menu-leaf.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-leaf.png" === node['src'] &&
        true
      end
    end
    class Element_190 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf\ >\ a$/

      def valid? # Rules count: 9
        (50..109) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_191 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (4..61) === to_html.size &&
        /^.*$/m === to_html &&
        (4..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_192 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf$/

      def valid? # Rules count: 9
        (185..259) === to_html.size &&
        /^<li\ class="leaf"\ nid="2.*$/m === to_html &&
        (4..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["a", "a"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "leaf" === node['class'] &&
(258064..273074) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_193 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        36 === to_html.size &&
        "<img src=\"/misc/menu-collapsed.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-collapsed.png" === node['src'] &&
        true
      end
    end
    class Element_194 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed\ >\ a$/

      def valid? # Rules count: 9
        (52..109) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_195 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (8..61) === to_html.size &&
        /^.*$/m === to_html &&
        (8..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_196 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed$/

      def valid? # Rules count: 9
        (195..256) === to_html.size &&
        /^<li\ class="collapsed"\ nid="2.*$/m === to_html &&
        (8..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["a", "a"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "collapsed" === node['class'] &&
(258059..273202) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_197 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu$/

      def valid? # Rules count: 9
        (216..15556) === to_html.size &&
        /^<ul\ class="menu">.*<\/ul>$/m === to_html &&
        (9..1642) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        (1..66) === children.count &&
        (children_tags - ["li"] == []) &&
        (children_classes - ["leaf", "collapsed", "expanded"] == []) &&
        (children_ids - [nil] == []) &&
        "menu" === node['class'] &&
        true
      end
    end
    class Element_198 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded$/

      def valid? # Rules count: 9
        (411..15762) === to_html.size &&
        /^<li\ class="expanded"\ nid="2.*$/m === to_html &&
        (27..1663) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        3 === children.count &&
        (children_tags - ["a", "a", "ul"] == []) &&
        (children_classes - [nil, nil, "menu"] == []) &&
        (children_ids - [nil, nil, nil] == []) &&
        "expanded" === node['class'] &&
(257314..271794) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_199 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.breadcrumb\ >\ text$/

      def valid? # Rules count: 9
        3 === to_html.size &&
        " » " === to_html &&
        3 === text.to_s.size &&
        " » " === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_200 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ p\ >\ text$/

      def valid? # Rules count: 9
        Set[30, 34].include?(to_html.size) &&
        Set["On Display : Table of Contents", "On Display : Title of Section Only"].include?(to_html) &&
        Set[30, 34].include?(text.to_s.size) &&
        Set["On Display : Table of Contents", "On Display : Title of Section Only"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_201 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ p$/

      def valid? # Rules count: 9
        Set[37, 41].include?(to_html.size) &&
        Set["<p>On Display : Table of Contents</p>", "<p>On Display : Title of Section Only</p>"].include?(to_html) &&
        Set[30, 34].include?(text.to_s.size) &&
        Set["On Display : Table of Contents", "On Display : Title of Section Only"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        
        true
      end
    end
    class Element_202 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (4..71) === to_html.size &&
        /^.*$/m === to_html &&
        (4..71) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_203 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ ul\.menu\ >\ li\.leaf\ >\ a$/

      def valid? # Rules count: 9
        (50..130) === to_html.size &&
        /^<a\ rel="link"\ href="\/tipitaka\/.*<\/a>$/m === to_html &&
        (4..71) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "link" === node['rel'] &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_204 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ ul\.menu\ >\ li\.leaf$/

      def valid? # Rules count: 9
        (108..187) === to_html.size &&
        /^<li\ class="leaf"\ nid="2.*$/m === to_html &&
        (4..71) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["a"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "leaf" === node['class'] &&
(257319..277392) === node['nid'] &&
"tipitaka_ajax_i" === node['rel'] &&
        true
      end
    end
    class Element_205 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ div\.page\-links\ clear\-block\ >\ a\.page\-previous\ >\ text$/

      def valid? # Rules count: 9
        (13..80) === to_html.size &&
        /^&lt;&lt;\ .*$/m === to_html &&
        (7..74) === text.to_s.size &&
        /^<<\ .*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_206 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ div\.page\-links\ clear\-block\ >\ a\.page\-previous$/

      def valid? # Rules count: 9
        (133..213) === to_html.size &&
        /^<a\ href="\/tipitaka\/.*<\/a>$/m === to_html &&
        (7..74) === text.to_s.size &&
        /^<<\ .*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        /^\/tipitaka\/.*$/m === node['href'] &&
(257283..277392) === node['nid'] &&
"tipitaka_ajax_i" === node['rel'] &&
"page-previous" === node['class'] &&
"Go to previous page" === node['title'] &&
        true
      end
    end
    class Element_207 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ div\.page\-links\ clear\-block\ >\ a\.page\-up\ >\ text$/

      def valid? # Rules count: 9
        2 === to_html.size &&
        "up" === to_html &&
        2 === text.to_s.size &&
        "up" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_208 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\.tipitaka\-navigation\ >\ div\.page\-links\ clear\-block\ >\ a\.page\-up$/

      def valid? # Rules count: 9
        (106..155) === to_html.size &&
        /^<a\ href="\/tipitaka\/.*"\ rel="tipitaka_ajax_i"\ class="page\-up"\ title="Go\ to\ parent\ page">up<\/a>$/m === to_html &&
        2 === text.to_s.size &&
        "up" === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        /^\/tipitaka\/.*$/m === node['href'] &&
(257283..276935) === node['nid'] &&
"tipitaka_ajax_i" === node['rel'] &&
"page-up" === node['class'] &&
"Go to parent page" === node['title'] &&
        true
      end
    end
    class Element_209 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.hidden\ >\ text$/

      def valid? # Rules count: 9
        (3..62) === to_html.size &&
        /^.*$/m === to_html &&
        (3..62) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_210 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.hidden$/

      def valid? # Rules count: 9
        (63..125) === to_html.size &&
        /^<div\ xmlns="http:\/\/www\.w3\.org\/1999\/xhtml"\ class="hidden">.*<\/div>$/m === to_html &&
        (0..62) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        Set[1, 0].include?(children.count) &&
        Set[["text"], []].include?(children_tags) &&
        Set[[nil], []].include?(children_classes) &&
        Set[[nil], []].include?(children_ids) &&
        "http://www.w3.org/1999/xhtml" === node['xmlns'] &&
"hidden" === node['class'] &&
        true
      end
    end
    class Element_211 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.divNumber\ >\ text$/

      def valid? # Rules count: 9
        Set[2, 3, 4, 7, 8, 9, 5, 6, 10, 11].include?(to_html.size) &&
        /^.*\.$/m === to_html &&
        Set[2, 3, 4, 7, 8, 9, 5, 6, 10, 11].include?(text.to_s.size) &&
        /^.*\.$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_212 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.divNumber$/

      def valid? # Rules count: 9
        Set[31, 32, 33, 36, 37, 38, 34, 35, 39, 40].include?(to_html.size) &&
        /^<div\ class="divNumber">.*<\/div>$/m === to_html &&
        Set[2, 3, 4, 7, 8, 9, 5, 6, 10, 11].include?(text.to_s.size) &&
        /^.*\.$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "divNumber" === node['class'] &&
        true
      end
    end
    class Element_213 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_214 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.paragraphNum\ >\ text$/

      def valid? # Rules count: 9
        Set[1, 2, 3, 4].include?(to_html.size) &&
        /^.*$/m === to_html &&
        Set[1, 2, 3, 4].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_215 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.paragraphNum$/

      def valid? # Rules count: 9
        Set[33, 34, 35, 36].include?(to_html.size) &&
        /^<div\ class="paragraphNum">.*<\/div>$/m === to_html &&
        Set[1, 2, 3, 4].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "paragraphNum" === node['class'] &&
        true
      end
    end
    class Element_216 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ text$/

      def valid? # Rules count: 9
        (1..53) === to_html.size &&
        /^.*$/m === to_html &&
        (1..53) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_217 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA$/

      def valid? # Rules count: 9
        (28..160) === to_html.size &&
        /^<div\ class="GATHA">.*<\/div>$/m === to_html &&
        (3..65) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        Set[1, 2, 3, 5, 4].include?(children.count) &&
        Set[["text"], ["text", "span"], ["span", "text"], ["text", "span", "text"], ["span"], ["span", "text", "span"], ["text", "span", "text", "span", "text"], ["span", "span"], ["span", "text", "span", "text"]].include?(children_tags) &&
        (children_classes - [nil, "gathaQuote", "RLAP", "smallFont", "bold"] == []) &&
        Set[[nil], [nil, nil], [nil, nil, nil], [nil, nil, nil, nil, nil], [nil, nil, nil, nil]].include?(children_ids) &&
        "GATHA" === node['class'] &&
        true
      end
    end
    class Element_218 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td$/

      def valid? # Rules count: 9
        (39..207) === to_html.size &&
        /^<td>\n<div\ class=".*<\/div>\n<\/td>$/m === to_html &&
        (5..69) === text.to_s.size &&
        /^\n.*\n$/m === text.to_s &&
        Set[5, 3].include?(children.count) &&
        Set[["text", "div", "text", "div", "text"], ["text", "div", "text"]].include?(children_tags) &&
        Set[[nil, "paragraphNum", nil, "GATHA", nil], [nil, "GATHA", nil]].include?(children_classes) &&
        Set[[nil, nil, nil, nil, nil], [nil, nil, nil]].include?(children_ids) &&
        
        true
      end
    end
    class Element_219 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_220 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr$/

      def valid? # Rules count: 9
        (50..219) === to_html.size &&
        /^<tr>\n<td>\n<div\ class=".*$/m === to_html &&
        (6..70) === text.to_s.size &&
        /^\n.*\n\n$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["td", "text"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        
        true
      end
    end
    class Element_221 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn$/

      def valid? # Rules count: 9
        (122..908) === to_html.size &&
        /^<table\ class="singleColumn">.*<\/table>$/m === to_html &&
        (10..299) === text.to_s.size &&
        /^\n.*\n\n$/m === text.to_s &&
        Set[4, 5, 6, 3, 2, 7, 8, 1, 12, 10].include?(children.count) &&
        (children_tags - ["tr", "tbody"] == []) &&
        Set[[nil, nil, nil, nil], [nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil], [nil, nil, nil], [nil, nil], [nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil], [nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]].include?(children_classes) &&
        Set[[nil, nil, nil, nil], [nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil], [nil, nil, nil], [nil, nil], [nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil], [nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]].include?(children_ids) &&
        "singleColumn" === node['class'] &&
        true
      end
    end
    class Element_222 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.CENTER\ >\ span\.paragraphNum\ >\ text$/

      def valid? # Rules count: 9
        Set[2, 3, 4, 1].include?(to_html.size) &&
        /^.*$/m === to_html &&
        Set[2, 3, 4, 1].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_223 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.CENTER\ >\ span\.paragraphNum$/

      def valid? # Rules count: 9
        Set[36, 37, 38, 35].include?(to_html.size) &&
        /^<span\ class="paragraphNum">.*<\/span>$/m === to_html &&
        Set[2, 3, 4, 1].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "paragraphNum" === node['class'] &&
        true
      end
    end
    class Element_224 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.CENTER\ >\ text$/

      def valid? # Rules count: 9
        (1..119) === to_html.size &&
        /^.*$/m === to_html &&
        (1..119) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_225 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.CENTER$/

      def valid? # Rules count: 9
        (119..250) === to_html.size &&
        /^<div\ xmlns="http:\/\/www\.w3\.org\/1999\/xhtml"\ class="CENTER"\ id="p_.*\n<\/div>$/m === to_html &&
        (7..130) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        Set[2, 4, 6, 8, 5, 3, 7].include?(children.count) &&
        Set[["span", "text"], ["span", "text", "br", "text"], ["span", "text", "br", "text", "br", "text"], ["span", "text", "br", "text", "br", "text", "br", "text"], ["span", "text", "br", "span"], ["text", "span", "text", "br", "text"], ["text", "span", "text"], ["text", "span", "text", "br", "text", "br", "text"]].include?(children_tags) &&
        Set[["paragraphNum", nil], ["paragraphNum", nil, nil, nil], ["paragraphNum", nil, nil, nil, nil, nil], ["paragraphNum", nil, nil, nil, nil, nil, nil, nil], ["paragraphNum", nil, nil, "bold"], [nil, "paragraphNum", nil, nil, nil], [nil, "paragraphNum", nil], [nil, "paragraphNum", nil, nil, nil, nil, nil]].include?(children_classes) &&
        Set[[nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil], [nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil]].include?(children_ids) &&
        "http://www.w3.org/1999/xhtml" === node['xmlns'] &&
"CENTER" === node['class'] &&
/^p_.*$/m === node['id'] &&
        true
      end
    end
    class Element_226 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.CENTER\ >\ br$/

      def valid? # Rules count: 9
        4 === to_html.size &&
        "<br>" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_227 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ span\.gathaQuote\ >\ text$/

      def valid? # Rules count: 9
        (8..26) === to_html.size &&
        /^\(.*\)$/m === to_html &&
        (8..26) === text.to_s.size &&
        /^\(.*\)$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_228 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ span\.gathaQuote$/

      def valid? # Rules count: 9
        (40..58) === to_html.size &&
        /^<span\ class="gathaQuote">\(.*\)<\/span>$/m === to_html &&
        (8..26) === text.to_s.size &&
        /^\(.*\)$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "gathaQuote" === node['class'] &&
        true
      end
    end
    class Element_229 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        35 === to_html.size &&
        "<img src=\"/misc/menu-expanded.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-expanded.png" === node['src'] &&
        true
      end
    end
    class Element_230 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ a$/

      def valid? # Rules count: 9
        (52..109) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_231 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (8..61) === to_html.size &&
        /^.*$/m === to_html &&
        (8..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_232 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        31 === to_html.size &&
        "<img src=\"/misc/menu-leaf.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-leaf.png" === node['src'] &&
        true
      end
    end
    class Element_233 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf\ >\ a$/

      def valid? # Rules count: 9
        (56..124) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..71) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_234 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (5..71) === to_html.size &&
        /^.*$/m === to_html &&
        (5..71) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_235 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf$/

      def valid? # Rules count: 9
        (195..265) === to_html.size &&
        /^<li\ class="leaf"\ nid="2.*$/m === to_html &&
        (5..71) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["a", "a"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "leaf" === node['class'] &&
(258810..276388) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_236 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu$/

      def valid? # Rules count: 9
        (219..13368) === to_html.size &&
        /^<ul\ class="menu">.*<\/ul>$/m === to_html &&
        (5..1562) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        (1..48) === children.count &&
        (children_tags - ["li"] == []) &&
        (children_classes - ["leaf", "collapsed", "expanded"] == []) &&
        (children_ids - [nil] == []) &&
        "menu" === node['class'] &&
        true
      end
    end
    class Element_237 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded$/

      def valid? # Rules count: 9
        (425..13594) === to_html.size &&
        /^<li\ class="expanded"\ nid="2.*$/m === to_html &&
        (19..1584) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        3 === children.count &&
        (children_tags - ["a", "a", "ul"] == []) &&
        (children_classes - [nil, nil, "menu"] == []) &&
        (children_ids - [nil, nil, nil] == []) &&
        "expanded" === node['class'] &&
(258059..273202) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_238 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.SUMMARY\ >\ span\.paragraphNum\ >\ text$/

      def valid? # Rules count: 9
        Set[3, 4, 2, 1].include?(to_html.size) &&
        /^.*$/m === to_html &&
        Set[3, 4, 2, 1].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_239 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.SUMMARY\ >\ span\.paragraphNum$/

      def valid? # Rules count: 9
        Set[37, 38, 36, 35].include?(to_html.size) &&
        /^<span\ class="paragraphNum">.*<\/span>$/m === to_html &&
        Set[3, 4, 2, 1].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "paragraphNum" === node['class'] &&
        true
      end
    end
    class Element_240 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.SUMMARY\ >\ span\.firstLetter\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        /^.*$/m === to_html &&
        1 === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_241 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.SUMMARY\ >\ span\.firstLetter$/

      def valid? # Rules count: 9
        34 === to_html.size &&
        /^<span\ class="firstLetter">.*<\/span>$/m === to_html &&
        1 === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "firstLetter" === node['class'] &&
        true
      end
    end
    class Element_242 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.SUMMARY\ >\ text$/

      def valid? # Rules count: 9
        (1..20) === to_html.size &&
        /^.*$/m === to_html &&
        (1..20) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_243 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.SUMMARY$/

      def valid? # Rules count: 9
        (159..327) === to_html.size &&
        /^<div\ xmlns="http:\/\/www\.w3\.org\/1999\/xhtml"\ class="SUMMARY"\ id="p_.*\n<\/div>$/m === to_html &&
        (11..47) === text.to_s.size &&
        /^.*\n$/m === text.to_s &&
        Set[3, 7, 5, 11, 4].include?(children.count) &&
        Set[["span", "span", "text"], ["span", "span", "text", "span", "text", "span", "text"], ["span", "span", "text", "span", "text"], ["span", "span", "text", "span", "text", "span", "text", "span", "text", "span", "text"], ["text", "span", "span", "text"]].include?(children_tags) &&
        Set[["paragraphNum", "firstLetter", nil], ["paragraphNum", "firstLetter", nil, "firstLetter", nil, "firstLetter", nil], ["paragraphNum", "firstLetter", nil, "firstLetter", nil], ["paragraphNum", "firstLetter", nil, "firstLetter", nil, "firstLetter", nil, "firstLetter", nil, "firstLetter", nil], [nil, "paragraphNum", "firstLetter", nil]].include?(children_classes) &&
        Set[[nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil]].include?(children_ids) &&
        "http://www.w3.org/1999/xhtml" === node['xmlns'] &&
"SUMMARY" === node['class'] &&
/^p_.*$/m === node['id'] &&
        true
      end
    end
    class Element_244 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\ >\ span\.paragraphNum\ >\ text$/

      def valid? # Rules count: 9
        Set[3, 4, 2].include?(to_html.size) &&
        /^.*$/m === to_html &&
        Set[3, 4, 2].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_245 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\ >\ span\.paragraphNum$/

      def valid? # Rules count: 9
        Set[37, 38, 36].include?(to_html.size) &&
        /^<span\ class="paragraphNum">.*<\/span>$/m === to_html &&
        Set[3, 4, 2].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "paragraphNum" === node['class'] &&
        true
      end
    end
    class Element_246 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\ >\ text$/

      def valid? # Rules count: 9
        (1..55) === to_html.size &&
        /^.*$/m === to_html &&
        (1..55) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_247 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div$/

      def valid? # Rules count: 9
        (128..192) === to_html.size &&
        /^<div\ xmlns="http:\/\/www\.w3\.org\/1999\/xhtml"\ class="ENDH3"\ id="p_.*\n<\/div>$/m === to_html &&
        (15..76) === text.to_s.size &&
        /^.*\n$/m === text.to_s &&
        Set[2, 5, 3, 4].include?(children.count) &&
        Set[["span", "text"], ["text", "span", "text", "br", "text"], ["text", "span", "text"], ["span", "text", "br", "text"]].include?(children_tags) &&
        Set[["paragraphNum", nil], [nil, "paragraphNum", nil, nil, nil], [nil, "paragraphNum", nil], ["paragraphNum", nil, nil, nil]].include?(children_classes) &&
        Set[[nil, nil], [nil, nil, nil, nil, nil], [nil, nil, nil], [nil, nil, nil, nil]].include?(children_ids) &&
        "http://www.w3.org/1999/xhtml" === node['xmlns'] &&
"ENDH3" === node['class'] &&
/^p_.*$/m === node['id'] &&
        true
      end
    end
    class Element_248 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ span\.bold\ >\ text$/

      def valid? # Rules count: 9
        (1..1735) === to_html.size &&
        /^.*$/m === to_html &&
        (1..1735) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_249 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ span\.bold$/

      def valid? # Rules count: 9
        (27..1761) === to_html.size &&
        /^<span\ class="bold">.*<\/span>$/m === to_html &&
        (1..1735) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "bold" === node['class'] &&
        true
      end
    end
    class Element_250 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ span\.smallFont\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        Set["“", "”", "‘", "’"].include?(to_html) &&
        1 === text.to_s.size &&
        Set["“", "”", "‘", "’"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_251 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ span\.smallFont$/

      def valid? # Rules count: 9
        32 === to_html.size &&
        Set["<span class=\"smallFont\">“</span>", "<span class=\"smallFont\">”</span>", "<span class=\"smallFont\">‘</span>", "<span class=\"smallFont\">’</span>"].include?(to_html) &&
        1 === text.to_s.size &&
        Set["“", "”", "‘", "’"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "smallFont" === node['class'] &&
        true
      end
    end
    class Element_252 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.ENDBOOK\ >\ span\.paragraphNum\ >\ text$/

      def valid? # Rules count: 9
        Set[4, 3].include?(to_html.size) &&
        /^.*$/m === to_html &&
        Set[4, 3].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_253 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.ENDBOOK\ >\ span\.paragraphNum$/

      def valid? # Rules count: 9
        Set[38, 37].include?(to_html.size) &&
        /^<span\ class="paragraphNum">.*<\/span>$/m === to_html &&
        Set[4, 3].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "paragraphNum" === node['class'] &&
        true
      end
    end
    class Element_254 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.ENDBOOK\ >\ text$/

      def valid? # Rules count: 9
        (1..38) === to_html.size &&
        /^.*$/m === to_html &&
        (1..38) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_255 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.ENDBOOK$/

      def valid? # Rules count: 9
        (138..158) === to_html.size &&
        /^<div\ xmlns="http:\/\/www\.w3\.org\/1999\/xhtml"\ class="ENDBOOK"\ id="p_.*<\/div>$/m === to_html &&
        (23..42) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        Set[2, 3].include?(children.count) &&
        Set[["span", "text"], ["text", "span", "text"]].include?(children_tags) &&
        Set[["paragraphNum", nil], [nil, "paragraphNum", nil]].include?(children_classes) &&
        Set[[nil, nil], [nil, nil, nil]].include?(children_ids) &&
        "http://www.w3.org/1999/xhtml" === node['xmlns'] &&
"ENDBOOK" === node['class'] &&
/^p_.*$/m === node['id'] &&
        true
      end
    end
    class Element_256 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        31 === to_html.size &&
        "<img src=\"/misc/menu-leaf.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-leaf.png" === node['src'] &&
        true
      end
    end
    class Element_257 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.leaf\ >\ a$/

      def valid? # Rules count: 9
        (52..99) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..55) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_258 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (7..55) === to_html.size &&
        /^.*$/m === to_html &&
        (7..55) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_259 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.leaf$/

      def valid? # Rules count: 9
        (182..232) === to_html.size &&
        /^<li\ class="leaf"\ nid="2.*$/m === to_html &&
        (7..55) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["a", "a"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "leaf" === node['class'] &&
(257319..276572) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_260 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        36 === to_html.size &&
        "<img src=\"/misc/menu-collapsed.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-collapsed.png" === node['src'] &&
        true
      end
    end
    class Element_261 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed\ >\ a$/

      def valid? # Rules count: 9
        (63..102) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..49) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_262 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (10..49) === to_html.size &&
        /^.*$/m === to_html &&
        (10..49) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_263 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed$/

      def valid? # Rules count: 9
        (214..254) === to_html.size &&
        /^<li\ class="collapsed"\ nid="2.*$/m === to_html &&
        (10..49) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["a", "a"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "collapsed" === node['class'] &&
(258760..274658) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_264 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        35 === to_html.size &&
        "<img src=\"/misc/menu-expanded.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-expanded.png" === node['src'] &&
        true
      end
    end
    class Element_265 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ a$/

      def valid? # Rules count: 9
        (63..101) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..49) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_266 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (10..49) === to_html.size &&
        /^.*$/m === to_html &&
        (10..49) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_267 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        36 === to_html.size &&
        "<img src=\"/misc/menu-collapsed.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-collapsed.png" === node['src'] &&
        true
      end
    end
    class Element_268 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed\ >\ a$/

      def valid? # Rules count: 9
        (62..117) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..34) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_269 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (5..34) === to_html.size &&
        /^.*$/m === to_html &&
        (5..34) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_270 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed$/

      def valid? # Rules count: 9
        (218..290) === to_html.size &&
        /^<li\ class="collapsed"\ nid="2.*$/m === to_html &&
        (5..34) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["a", "a"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "collapsed" === node['class'] &&
(260453..276935) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_271 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        31 === to_html.size &&
        "<img src=\"/misc/menu-leaf.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-leaf.png" === node['src'] &&
        true
      end
    end
    class Element_272 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf\ >\ a$/

      def valid? # Rules count: 9
        (62..128) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..59) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_273 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (5..59) === to_html.size &&
        /^.*$/m === to_html &&
        (5..59) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_274 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf$/

      def valid? # Rules count: 9
        (207..286) === to_html.size &&
        /^<li\ class="leaf"\ nid="2.*$/m === to_html &&
        (5..59) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["a", "a"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "leaf" === node['class'] &&
(259998..277313) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_275 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu$/

      def valid? # Rules count: 9
        (229..11343) === to_html.size &&
        /^<ul\ class="menu">.*<\/ul>$/m === to_html &&
        (5..1300) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        (1..46) === children.count &&
        (children_tags - ["li"] == []) &&
        (children_classes - ["collapsed", "leaf", "expanded"] == []) &&
        (children_ids - [nil] == []) &&
        "menu" === node['class'] &&
        true
      end
    end
    class Element_276 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded$/

      def valid? # Rules count: 9
        (444..11575) === to_html.size &&
        /^<li\ class="expanded"\ nid="2.*$/m === to_html &&
        (17..1325) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        3 === children.count &&
        (children_tags - ["a", "a", "ul"] == []) &&
        (children_classes - [nil, nil, "menu"] == []) &&
        (children_ids - [nil, nil, nil] == []) &&
        "expanded" === node['class'] &&
(258760..274658) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_277 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        35 === to_html.size &&
        "<img src=\"/misc/menu-expanded.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-expanded.png" === node['src'] &&
        true
      end
    end
    class Element_278 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ a$/

      def valid? # Rules count: 9
        (62..116) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..34) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_279 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (5..34) === to_html.size &&
        /^.*$/m === to_html &&
        (5..34) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_280 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        31 === to_html.size &&
        "<img src=\"/misc/menu-leaf.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-leaf.png" === node['src'] &&
        true
      end
    end
    class Element_281 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf\ >\ a$/

      def valid? # Rules count: 9
        (70..127) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..51) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/.*$/m === node['href'] &&
        true
      end
    end
    class Element_282 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (5..51) === to_html.size &&
        /^.*$/m === to_html &&
        (5..51) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_283 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.leaf$/

      def valid? # Rules count: 9
        (223..303) === to_html.size &&
        /^<li\ class="leaf"\ nid="2.*$/m === to_html &&
        (5..51) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["a", "a"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "leaf" === node['class'] &&
(262061..277392) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_284 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu$/

      def valid? # Rules count: 9
        (245..5876) === to_html.size &&
        /^<ul\ class="menu">.*<\/ul>$/m === to_html &&
        (5..500) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        (1..24) === children.count &&
        (children_tags - ["li"] == []) &&
        (children_classes - ["leaf", "collapsed"] == []) &&
        (children_ids - [nil] == []) &&
        "menu" === node['class'] &&
        true
      end
    end
    class Element_285 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded$/

      def valid? # Rules count: 9
        (474..6111) === to_html.size &&
        /^<li\ class="expanded"\ nid="2.*$/m === to_html &&
        (14..519) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        3 === children.count &&
        (children_tags - ["a", "a", "ul"] == []) &&
        (children_classes - [nil, nil, "menu"] == []) &&
        (children_ids - [nil, nil, nil] == []) &&
        "expanded" === node['class'] &&
(260453..276935) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_286 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed\ >\ a\ >\ img$/

      def valid? # Rules count: 9
        36 === to_html.size &&
        "<img src=\"/misc/menu-collapsed.png\">" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        "/misc/menu-collapsed.png" === node['src'] &&
        true
      end
    end
    class Element_287 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed\ >\ a$/

      def valid? # Rules count: 9
        (70..123) === to_html.size &&
        /^<a\ rel=".*<\/a>$/m === to_html &&
        (0..35) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        Set[["img"], ["text"]].include?(children_tags) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        Set["icon", "link"].include?(node['rel']) &&
/^\/tipitaka\/3.*$/m === node['href'] &&
        true
      end
    end
    class Element_288 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed\ >\ a\ >\ text$/

      def valid? # Rules count: 9
        (5..35) === to_html.size &&
        /^.*$/m === to_html &&
        (5..35) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_289 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#sidebar\-left\ >\ div\#sidebar\-left\-div\ >\ div\.block\ block\-tipitaka\ >\ div\.content\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.expanded\ >\ ul\.menu\ >\ li\.collapsed$/

      def valid? # Rules count: 9
        (234..300) === to_html.size &&
        /^<li\ class="collapsed"\ nid="2.*$/m === to_html &&
        (5..35) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["a", "a"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        "collapsed" === node['class'] &&
(262089..271534) === node['nid'] &&
"tipitaka_ajax" === node['rel'] &&
        true
      end
    end
    class Element_290 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ span\.RLAP\ >\ text$/

      def valid? # Rules count: 9
        Set[11, 4].include?(to_html.size) &&
        Set["saniddesaṃ,", "(16)"].include?(to_html) &&
        Set[11, 4].include?(text.to_s.size) &&
        Set["saniddesaṃ,", "(16)"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_291 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ span\.RLAP$/

      def valid? # Rules count: 9
        Set[37, 77, 30].include?(to_html.size) &&
        Set["<span class=\"RLAP\">saniddesaṃ,</span>", "<span class=\"RLAP\"><span class=\"gathaQuote\">(iccāyasmā dhotako)</span></span>", "<span class=\"RLAP\">(16)</span>"].include?(to_html) &&
        Set[11, 19, 4].include?(text.to_s.size) &&
        Set["saniddesaṃ,", "(iccāyasmā dhotako)", "(16)"].include?(text.to_s) &&
        1 === children.count &&
        Set[["text"], ["span"]].include?(children_tags) &&
        Set[[nil], ["gathaQuote"]].include?(children_classes) &&
        (children_ids - [nil] == []) &&
        "RLAP" === node['class'] &&
        true
      end
    end
    class Element_292 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ h2\.paliSectionName\ >\ span\.paragraphNum\ >\ text$/

      def valid? # Rules count: 9
        Set[3, 4].include?(to_html.size) &&
        /^.*$/m === to_html &&
        Set[3, 4].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_293 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ h2\.paliSectionName\ >\ span\.paragraphNum$/

      def valid? # Rules count: 9
        Set[37, 38].include?(to_html.size) &&
        /^<span\ class="paragraphNum">.*<\/span>$/m === to_html &&
        Set[3, 4].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "paragraphNum" === node['class'] &&
        true
      end
    end
    class Element_294 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ h2\.paliSectionName\ >\ text$/

      def valid? # Rules count: 9
        (10..45) === to_html.size &&
        /^.*$/m === to_html &&
        (10..45) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_295 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ h2\.paliSectionName\ >\ br$/

      def valid? # Rules count: 9
        4 === to_html.size &&
        "<br>" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_296 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ h2\.paliSectionName$/

      def valid? # Rules count: 9
        (86..121) === to_html.size &&
        /^<h2\ class="paliSectionName">\n<span\ class="paragraphNum">.*<br>\n<\/h2>$/m === to_html &&
        (13..48) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        3 === children.count &&
        (children_tags - ["span", "text", "br"] == []) &&
        (children_classes - ["paragraphNum", nil, nil] == []) &&
        (children_ids - [nil, nil, nil] == []) &&
        "paliSectionName" === node['class'] &&
        true
      end
    end
    class Element_297 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ span\.italic\ >\ text$/

      def valid? # Rules count: 9
        Set[12, 35, 1, 2, 3].include?(to_html.size) &&
        /^.*$/m === to_html &&
        Set[12, 35, 1, 2, 3].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_298 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ span\.italic$/

      def valid? # Rules count: 9
        Set[40, 63, 29, 30, 31].include?(to_html.size) &&
        /^<span\ class="italic">.*<\/span>$/m === to_html &&
        Set[12, 35, 1, 2, 3].include?(text.to_s.size) &&
        /^.*$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "italic" === node['class'] &&
        true
      end
    end
    class Element_299 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ span\.smallFont\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        Set["“", "”"].include?(to_html) &&
        1 === text.to_s.size &&
        Set["“", "”"].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_300 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ span\.smallFont$/

      def valid? # Rules count: 9
        32 === to_html.size &&
        Set["<span class=\"smallFont\">“</span>", "<span class=\"smallFont\">”</span>"].include?(to_html) &&
        1 === text.to_s.size &&
        Set["“", "”"].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "smallFont" === node['class'] &&
        true
      end
    end
    class Element_301 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.CENTER\ >\ span\.bold\ >\ text$/

      def valid? # Rules count: 9
        Set[23, 18, 29, 36, 28, 31].include?(to_html.size) &&
        Set["Khattiyāvaggo catuttho.", "Sudhāvaggo dasamo.", "Tamālapupphiyavaggo vīsatimo.", "Suvaṇṇabibbohanavaggo aṭṭhavīsatimo.", "Citakapūjakavaggo tiṃsatimo.", "Pilindavacchavaggo cattālīsamo.", "Kiṅkaṇipupphavaggo paññāsamo."].include?(to_html) &&
        Set[23, 18, 29, 36, 28, 31].include?(text.to_s.size) &&
        Set["Khattiyāvaggo catuttho.", "Sudhāvaggo dasamo.", "Tamālapupphiyavaggo vīsatimo.", "Suvaṇṇabibbohanavaggo aṭṭhavīsatimo.", "Citakapūjakavaggo tiṃsatimo.", "Pilindavacchavaggo cattālīsamo.", "Kiṅkaṇipupphavaggo paññāsamo."].include?(text.to_s) &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_302 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.CENTER\ >\ span\.bold$/

      def valid? # Rules count: 9
        Set[49, 44, 55, 62, 54, 57].include?(to_html.size) &&
        Set["<span class=\"bold\">Khattiyāvaggo catuttho.</span>", "<span class=\"bold\">Sudhāvaggo dasamo.</span>", "<span class=\"bold\">Tamālapupphiyavaggo vīsatimo.</span>", "<span class=\"bold\">Suvaṇṇabibbohanavaggo aṭṭhavīsatimo.</span>", "<span class=\"bold\">Citakapūjakavaggo tiṃsatimo.</span>", "<span class=\"bold\">Pilindavacchavaggo cattālīsamo.</span>", "<span class=\"bold\">Kiṅkaṇipupphavaggo paññāsamo.</span>"].include?(to_html) &&
        Set[23, 18, 29, 36, 28, 31].include?(text.to_s.size) &&
        Set["Khattiyāvaggo catuttho.", "Sudhāvaggo dasamo.", "Tamālapupphiyavaggo vīsatimo.", "Suvaṇṇabibbohanavaggo aṭṭhavīsatimo.", "Citakapūjakavaggo tiṃsatimo.", "Pilindavacchavaggo cattālīsamo.", "Kiṅkaṇipupphavaggo paññāsamo."].include?(text.to_s) &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "bold" === node['class'] &&
        true
      end
    end
    class Element_303 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ span\.RLAP\ >\ span\.gathaQuote\ >\ text$/

      def valid? # Rules count: 9
        19 === to_html.size &&
        "(iccāyasmā dhotako)" === to_html &&
        19 === text.to_s.size &&
        "(iccāyasmā dhotako)" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_304 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ span\.RLAP\ >\ span\.gathaQuote$/

      def valid? # Rules count: 9
        51 === to_html.size &&
        "<span class=\"gathaQuote\">(iccāyasmā dhotako)</span>" === to_html &&
        19 === text.to_s.size &&
        "(iccāyasmā dhotako)" === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "gathaQuote" === node['class'] &&
        true
      end
    end
    class Element_305 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ span\.bold\ >\ text$/

      def valid? # Rules count: 9
        (1..44) === to_html.size &&
        /^.*$/m === to_html &&
        (1..44) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_306 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ span\.bold\ >\ span\.gathaQuote\ >\ text$/

      def valid? # Rules count: 9
        Set[17, 25, 20, 19, 18, 21, 23].include?(to_html.size) &&
        /^\(.*\)$/m === to_html &&
        Set[17, 25, 20, 19, 18, 21, 23].include?(text.to_s.size) &&
        /^\(.*\)$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_307 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ span\.bold\ >\ span\.gathaQuote$/

      def valid? # Rules count: 9
        Set[49, 57, 52, 51, 50, 53, 55].include?(to_html.size) &&
        /^<span\ class="gathaQuote">\(.*\)<\/span>$/m === to_html &&
        Set[17, 25, 20, 19, 18, 21, 23].include?(text.to_s.size) &&
        /^\(.*\)$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "gathaQuote" === node['class'] &&
        true
      end
    end
    class Element_308 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ span\.bold$/

      def valid? # Rules count: 9
        (27..119) === to_html.size &&
        /^<span\ class="bold">.*<\/span>$/m === to_html &&
        (1..61) === text.to_s.size &&
        /^.*$/m === text.to_s &&
        Set[2, 1].include?(children.count) &&
        Set[["text", "span"], ["text"], ["span"]].include?(children_tags) &&
        Set[[nil, "gathaQuote"], [nil], ["gathaQuote"]].include?(children_classes) &&
        Set[[nil, nil], [nil]].include?(children_ids) &&
        "bold" === node['class'] &&
        true
      end
    end
    class Element_309 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tbody\ >\ tr\ >\ td\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_310 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tbody\ >\ tr\ >\ td\ >\ div\.paragraphNum\ >\ text$/

      def valid? # Rules count: 9
        Set[12, 10, 11].include?(to_html.size) &&
        /^\n\t\t\t.*\n\t\t\t$/m === to_html &&
        Set[12, 10, 11].include?(text.to_s.size) &&
        /^\n\t\t\t.*\n\t\t\t$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_311 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tbody\ >\ tr\ >\ td\ >\ div\.paragraphNum$/

      def valid? # Rules count: 9
        Set[44, 42, 43].include?(to_html.size) &&
        /^<div\ class="paragraphNum">\n\t\t\t.*\n\t\t\t<\/div>$/m === to_html &&
        Set[12, 10, 11].include?(text.to_s.size) &&
        /^\n\t\t\t.*\n\t\t\t$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "paragraphNum" === node['class'] &&
        true
      end
    end
    class Element_312 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tbody\ >\ tr\ >\ td\ >\ div\.GATHA\ >\ text$/

      def valid? # Rules count: 9
        (26..41) === to_html.size &&
        /^\n\t\t\t.*\n\t\t\t$/m === to_html &&
        (26..41) === text.to_s.size &&
        /^\n\t\t\t.*\n\t\t\t$/m === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_313 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tbody\ >\ tr\ >\ td\ >\ div\.GATHA$/

      def valid? # Rules count: 9
        (51..66) === to_html.size &&
        /^<div\ class="GATHA">\n\t\t\t.*\n\t\t\t<\/div>$/m === to_html &&
        (26..41) === text.to_s.size &&
        /^\n\t\t\t.*\n\t\t\t$/m === text.to_s &&
        1 === children.count &&
        (children_tags - ["text"] == []) &&
        (children_classes - [nil] == []) &&
        (children_ids - [nil] == []) &&
        "GATHA" === node['class'] &&
        true
      end
    end
    class Element_314 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tbody\ >\ tr\ >\ td$/

      def valid? # Rules count: 9
        (62..120) === to_html.size &&
        /^<td>\n<div\ class=".*\n\t\t\t<\/div>\n<\/td>$/m === to_html &&
        (28..54) === text.to_s.size &&
        /^\n\n\t\t\t.*\n\t\t\t\n$/m === text.to_s &&
        Set[5, 3].include?(children.count) &&
        Set[["text", "div", "text", "div", "text"], ["text", "div", "text"]].include?(children_tags) &&
        Set[[nil, "paragraphNum", nil, "GATHA", nil], [nil, "GATHA", nil]].include?(children_classes) &&
        Set[[nil, nil, nil, nil, nil], [nil, nil, nil]].include?(children_ids) &&
        
        true
      end
    end
    class Element_315 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tbody\ >\ tr\ >\ text$/

      def valid? # Rules count: 9
        1 === to_html.size &&
        "\n" === to_html &&
        1 === text.to_s.size &&
        "\n" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end
    class Element_316 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tbody\ >\ tr$/

      def valid? # Rules count: 9
        (74..132) === to_html.size &&
        /^<tr>\n<td>\n<div\ class=".*$/m === to_html &&
        (29..55) === text.to_s.size &&
        /^\n\n\t\t\t.*\n\t\t\t\n\n$/m === text.to_s &&
        2 === children.count &&
        (children_tags - ["td", "text"] == []) &&
        (children_classes - [nil, nil] == []) &&
        (children_ids - [nil, nil] == []) &&
        
        true
      end
    end
    class Element_317 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\.quotation\ >\ div\.paragraph\ >\ table\.singleColumn\ >\ tbody$/

      def valid? # Rules count: 9
        (366..533) === to_html.size &&
        /^<tbody>\n<tr>\n<td>\n<div\ class="paragraphNum">\n\t\t\t.*\.\n\t\t\t<\/div>\n<\/td>\n<\/tr>\n<\/tbody>$/m === to_html &&
        (138..215) === text.to_s.size &&
        /^\n\n\t\t\t.*\.\n\t\t\t\n\n$/m === text.to_s &&
        Set[4, 6].include?(children.count) &&
        Set[["tr", "tr", "tr", "tr"], ["tr", "tr", "tr", "tr", "tr", "tr"]].include?(children_tags) &&
        Set[[nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil]].include?(children_classes) &&
        Set[[nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil]].include?(children_ids) &&
        
        true
      end
    end
    class Element_318 < Base
      MATCH = /^document\ >\ html\ >\ body\ >\ table\#content\ >\ tr\ >\ td\#table\-main\ >\ div\#main\ >\ div\.node\ >\ div\.content\ >\ div\#tipitakaBodyWrapper\ >\ div\.tipitakaNode\ >\ div\ >\ br$/

      def valid? # Rules count: 9
        4 === to_html.size &&
        "<br>" === to_html &&
        0 === text.to_s.size &&
        "" === text.to_s &&
        0 === children.count &&
        (children_tags - [] == []) &&
        (children_classes - [] == []) &&
        (children_ids - [] == []) &&
        
        true
      end
    end

  end
end
end