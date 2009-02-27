module Brushup::Formatting
  @@formatters = {}
  @@format_types = []

  def self.format_types
    @@format_types
  end
  
  def self.register(name, formatter)
    name = self.name_to_sym(name)
    raise ArgumentError, "format name '#{name}' is already taken" if @@formatters[name]
    @@formatters[name] = formatter
    @@format_types << name
  end
    
  def self.formatter_for(name)
    name = self.name_to_sym(name)
    formatter = @@formatters[name]
    formatter || Brushup::Formatting::DefaultFormatter
  end
    
  def self.to_html(format, text)
    formatter_for(format).new(text).to_html
  end

  class DefaultFormatter
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    def initialize(text)
      @text = text
    end
    
    def to_html(*args)
      simple_format(auto_link(CGI::escapeHTML(@text)))
    end
  end

  private
  def self.name_to_sym(str)
    str = "_default" unless str
    str = str.to_sym
  end
end
