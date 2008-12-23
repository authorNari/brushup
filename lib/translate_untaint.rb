module ActionView
  module Helpers
    module TranslationHelper
      def translate_with_untaint(key, options = {})
        return translate_without_untaint(key, options).dup.untaint
      end
      alias_method_chain :translate, :untaint
      alias :t :translate_with_untaint
    end
  end
end

module ActionController
  module Translation
    def translate_with_untaint(key, options = {})
      return translate_without_untaint(key, options).dup.untaint
    end
    alias_method_chain :translate, :untaint
    alias :t :translate_with_untaint
  end
end
