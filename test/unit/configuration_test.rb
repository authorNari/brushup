require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  test "instance" do
    2.times do 
      config = Configuration.instance
      assert_equal 1, config.id
    end
  end
end
