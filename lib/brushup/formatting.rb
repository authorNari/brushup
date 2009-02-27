module Brushup::Formatting
  @@formatters = {}
  @@formatter_keys = []

  def self.formatter_keys
    @@formatter_keys
  end
  
  def self.register(name, formatter)
    name = name.to_sym
    raise ArgumentError, "format name '#{name}' is already taken" if @@formatters[name]
    @@formatters[name] = formatter
    @@formatter_keys << name
  end
    
  def self.formatter_for(name)
    formatter = @@formatters[name.to_sym]
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
end
