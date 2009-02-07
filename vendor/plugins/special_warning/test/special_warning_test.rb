require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/specialwarning')

class SpecialWarningTest < Test::Unit::TestCase
  def test_string_warning_check
    "String" == 1
  end
  
  def test_integer_warning_check
    1 == "String"
  end
  
  def test_float_warning_check
    1.0 == "String"
  end
end
