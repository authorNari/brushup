require 'redcloth3'

module Brushup::Formatting
  class TextileFormatter < RedCloth3
    
    RULES = [:textile]
    
    def initialize(*args)
      super
      self.hard_breaks=true
      self.no_span_caps=true
      self.filter_styles=true
    end
    
    def to_html(*rules, &block)
      @toc = []
      @macros_runner = block
      super(*RULES).to_s
    end
    
    private
    def hard_break( text ) 
      text.gsub!( /(.)\n(?!\n|\Z|>| *(>? *[#*=]+(\s|$)|[{|]))/, "\\1<br />\n" ) if hard_breaks 
    end
  end
end
