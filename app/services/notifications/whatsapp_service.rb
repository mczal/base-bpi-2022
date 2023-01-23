# frozen_string_literal: true

module Notifications
  class WhatsappService
    attr_reader :success

    def initialize user, message
      @user = user
      @message = message
      @success = true
    end

    def send
      lookups_phone_number

      Rails.logger.info(
        <<-EOS
          [NOTIFICATION][WHATSAPP_SERVICE] BEGIN Sending whatsapp notification with
          user: #{@user.to_json},
          message: #{@message},
        EOS
      )

      client.messages.create **whatsapp_params

      Rails.logger.info(
        <<-EOS
          [NOTIFICATION][WHATSAPP_SERVICE] END Sending whatsapp notification
        EOS
      )

    rescue => e
      Rails.logger.error(
        <<-EOS
          [NOTIFICATION][WHATSAPP_SERVICE][ERROR]
          Sending whatsapp failed
          #{e}
        EOS
      )
    end

    def lookups_phone_number
      lookup_client = Twilio::REST::Client.new
      valid_phone_number = lookup_client.lookups.phone_numbers(@user.formatted_phone)
      valid_phone_number.fetch
    end

    private
      def client
        return @client if @client.present?
        @client = Twilio::REST::Client.new
      end

      def whatsapp_params
        {
          to: "whatsapp:#{@user.formatted_phone}",
          body: @message.strip,
          from: "whatsapp:#{$twilio_config.phone_number}"
        }
      end
  end
end

