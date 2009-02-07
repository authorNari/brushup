module SpecialWarning
  module EqualsClassChecker
    def equals_class_check(target, klass)
      if target.is_a?(klass) && skip_warning?(target)
        ::SpecialWarning.warning("#{self} == #{target}: #{self.class} == #{target.class} comparison.")
      end
    end

    def skip_warning?(target)
      return (!@@skip_wards.include?(self.to_s) && !@@skip_wards.include?(target.to_s))
    end

    def self.skippables=(words=[])
      @@skip_wards = words
    end
    
    def self.skippables
      return @@skip_wards
    end
  end
end

# setting skippable wards
# for ERB '-'
# for rails-fixture "$LABEL"
# for rails-routes "$LABEL"
SpecialWarning::EqualsClassChecker.skippables = ["-", "$LABEL", "", "0"]

class String
  include SpecialWarning::EqualsClassChecker
  alias_method(:equals_without_warning?, :==)
  
  def ==(target)
    equals_class_check(target, Numeric)
    return equals_without_warning?(target)
  end
end

class Integer
  include SpecialWarning::EqualsClassChecker
  alias_method(:equals_without_warning?, :==)
  
  def ==(target)
    equals_class_check(target, String)
    return equals_without_warning?(target)
  end
end

class Float
  include SpecialWarning::EqualsClassChecker
  alias_method(:equals_without_warning?, :==)
  
  def ==(target)
    equals_class_check(target, String)
    return equals_without_warning?(target)
  end
end
