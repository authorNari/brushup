# I18n.t の文字変換時に taint されるため，safe_erb, safe_record でエラー
# に引っかかります．そのため translate 時にオブジェクトを untaint します．
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
