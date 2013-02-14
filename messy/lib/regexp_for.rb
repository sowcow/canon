def head str1, str2
  str2 = str2.chars
  str1.chars.take_while { |c| c == str2.shift }.join
end

def tail str1, str2
  head(str1.reverse, str2.reverse).reverse
end

def regexp_for strings
  s1, s2 = *strings.shift(2)
  h = head(s1, s2)
  t = tail(s1, s2)
  strings.each do |s|
    h = head(h, s)
    t = tail(t, s)
  end
  re = /^#{Regexp.escape h}.*#{Regexp.escape t}$/
  re =~ s1 ? re : /^#{Regexp.escape h}$/
end

ANY_STRING = /^.*$/

if __FILE__ == $0
  raise unless head('1', '12') == '1'
  raise unless head('12', '1') == '1'
  raise unless head('123', '12s') == '12'
  raise unless head('123', '123') == '123'

  raise unless tail('123', '12s') == ''
  raise unless tail('123', '123') == '123'
  raise unless tail('123', 'x23') == '23'

  raise unless regexp_for(['123', '12']) == /^12.*$/
  raise unless regexp_for(['1', '12x']) == /^1.*$/
  raise unless regexp_for(['123xx', '12xx']) == /^12.*xx$/

  raise unless regexp_for(['123', '123453', '103']) == /^1.*3$/
  raise unless regexp_for(['123', '123453', '104']) == /^1.*$/
  raise unless regexp_for(['123', '123453', '004']) == ANY_STRING
  raise unless regexp_for(['123', '123']) =~ '123'
  raise unless ANY_STRING =~ "sd\n\f312f"


  # s1 = %'<li class="collapsed" nid="25825.*aduka</a>\n</li>\n'
  # s2 = %'<li class="collapsed" nid="258258" rel="tipitaka_ajax'
  # p tail(s1, s2)

  puts 'OK'
end