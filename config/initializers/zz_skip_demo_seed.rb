# frozen_string_literal: true

# Выключатель демо-сида для боевых инстансов.
#
# `docker/prod/supervisord` гонит `rake db:seed` при каждом старте контейнера,
# а сидеры демо-данных гейтятся по «пусто ли ещё» (например
# DemoData::GroupSeeder#applicable? — это `Group.count.zero?`). На живом
# инстансе, где групп просто никто не заводил, апгрейд на новую мажорную
# версию из-за этого создаёт 7 демо-групп и полтора десятка демо-пользователей
# вроде marko.marketing.
#
# При OPENPROJECT_SKIP_DEMO_SEED=true весь DemoDataSeeder становится no-op.
# По умолчанию флаг выключен, поведение upstream не меняется.
if ActiveModel::Type::Boolean.new.cast(ENV.fetch("OPENPROJECT_SKIP_DEMO_SEED", false))
  Rails.application.config.to_prepare do
    DemoDataSeeder.class_eval do
      def seed!
        Rails.logger.info("[skip-demo-seed] DemoDataSeeder пропущен (OPENPROJECT_SKIP_DEMO_SEED=true)")
      end
    end
  end
end
