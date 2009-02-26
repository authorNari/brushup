module Defv
  module SessionLifetime
    module ClassMethods
      def expires_session options = {}
        cattr_accessor :_session_expiry
        cattr_accessor :_redirect_to
        cattr_accessor :_on_session_create
        cattr_accessor :_on_session_expiry
        
        self._session_expiry = options[:time] || 1.hour
        self._redirect_to = options[:redirect_to] || '/'
        self._on_session_create = options[:on_session_create]
        self._on_session_expiry = options[:on_session_expiry]
        
        self.before_filter :check_session_lifetime
      end
    end
    
    module InstanceMethods
        protected
        
        def check_session_lifetime
          if session[:updated_at] == nil
            # new session
            execute_method(:_on_session_create)
            session[:updated_at] = Time.now
          elsif session[:updated_at] && session[:updated_at] + self._session_expiry < Time.now
            reset_session
            execute_method(:_on_session_create)
            redirect_to self._redirect_to
            execute_method(:_on_session_expiry)
          else
            session[:updated_at] = Time.now
          end
        end
        
        def execute_method(method)
          method = method.to_s
          if self.send(method)
            if self.method(method).arity == 1
              self.method(method).call(self)
            else
              instance_eval(&self.method(method))
            end
          else
            hidden_methods = self.private_methods + self.protected_methods
            if hidden_methods.include?(method.sub(/^_/,''))
              self.send(method.sub(/^_/,'')) 
            end
          end
        end
    end
    
    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end