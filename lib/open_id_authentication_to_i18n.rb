module OpenIdAuthenticationToI18n
  def self.included(recipient)
    recipient.class_eval do
      OpenIdAuthentication::Result::ERROR_MESSAGES[:missing] = I18n.t(:missing, :scope => %w(open_id errors))
      OpenIdAuthentication::Result::ERROR_MESSAGES[:invalid] = I18n.t(:invalid, :scope => %w(open_id errors))
      OpenIdAuthentication::Result::ERROR_MESSAGES[:canceled] = I18n.t(:canceled, :scope => %w(open_id errors))
      OpenIdAuthentication::Result::ERROR_MESSAGES[:failed] = I18n.t(:failed, :scope => %w(open_id errors))
      OpenIdAuthentication::Result::ERROR_MESSAGES[:setup_needed] = I18n.t(:setup_needed, :scope => %w(open_id errors))
    end
  end
end
