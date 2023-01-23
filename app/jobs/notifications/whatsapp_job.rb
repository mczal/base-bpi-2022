# frozen_string_literal: true

module Notifications
  class WhatsappJob < ApplicationJob
    queue_as :default

    def perform user_id, message
      user = User.find_by id: user_id
      if !user.present?
        Rails.logger.error "[NOTIFICATIONS][WHATSAPP_JOB][ERROR] User not found id: #{user_id}"
        return
      end

      whatsapp_notification_service = Notifications::WhatsappService.new user, message
      whatsapp_notification_service.send
    end
  end
end

