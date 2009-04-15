# xmlに日本語を記述すると文字参照にされていたのでこれを修正．
class String
  def to_xs
    ERB::Util.h(unpack('U*').pack('U*')).gsub("'", '&apos;') # ASCII, UTF-8
  rescue
    unpack('C*').map {|n| n.xchr}.join # ISO-8859-1, WIN-1252
  end
end
