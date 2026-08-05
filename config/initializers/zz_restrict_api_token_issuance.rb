# frozen_string_literal: true

# Выпуск API-токенов — только глобальному администратору.
#
# В стоковом OpenProject `My::AccessTokensController#generate_api_key` помечен
# как `no_authorization_required!`, т.е. любой залогиненный пользователь может
# сам себе выпустить API-ключ (обходит 2FA и не виден админу).
#
# Тот же экшен обслуживает и iCal-токены встреч (`params[:token_ical_meeting]`),
# поэтому гейт срабатывает только на выпуск API-ключа. Отзыв (revoke_api_key)
# не трогаем — пользователь должен уметь отозвать свой токен.
#
# Раньше жил bind-mount'ом /opt/openproject/patches/ на hy; перенесён в репозиторий
# вместе с переездом bo.hesoyam.biz на сборку из этого форка.
Rails.application.config.to_prepare do
  My::AccessTokensController.class_eval do
    before_action :require_admin_for_api_token_issuance, only: %i[generate_api_key]

    def require_admin_for_api_token_issuance
      return if params[:token_api].blank?
      return if User.current.admin?

      Rails.logger.warn(
        "[api-token-guard] blocked API token issuance: user=#{User.current.id} ip=#{request.remote_ip}"
      )
      head :forbidden
    end

    private :require_admin_for_api_token_issuance
  end
end
