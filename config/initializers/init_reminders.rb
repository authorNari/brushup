begin
  require 'translate_untaint'
  require 'date'
  require 'friendly_id'
  require 'fixed_sting_to_xs'
  
  # tag init
  TagList.delimiter = " "
  Tag.destroy_unused = true
  
rescue Exception => ex
  puts "\nSigmas initialization failure."
  puts "\nPlease check config/initializers/inflections.rb"
  puts "\nError Class:\n\n #{ex.class}"
  puts "\nError Messages:\n\n  #{ex.message}"
  puts "\nError Backtrace:\n\n  #{ex.backtrace.join("\n  ")}"
  exit(1)
end

