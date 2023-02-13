module Api
  module Authorizable extend ActiveSupport::Concern
    include DateHelper

    def encrypt_data payload
      @encrypted_data ||= crypt.encrypt_and_sign(payload, expires_in: 10.minutes)
    end

    def decrypted_data
      return @decrypted_data if @decrypted_data.present?
      return return_unauthorize unless params[:body].present?

      @decrypted_data = crypt.decrypt_and_verify(params[:body])
      return return_unauthorize unless @decrypted_data.present?
      @decrypted_data
    end

    def return_unauthorize
      return render json: {
        status: 'UNAUTHORIZED',
        code: 401,
        message: "token authorization failed to verify.",
      }, status: :unauthorized
    end

    def crypt
      @crypt ||= ActiveSupport::MessageEncryptor.new(api_key)
    end

    def api_key
      ActiveSupport::KeyGenerator.new(api_pass).generate_key(ENV['API_SALT'], 32)
    end
    def api_pass
      "#{ENV["API_PASS"]}:#{salted_date_for_pass}"
    end
    def salted_date_for_pass
      pass_salted_date(DateTime.now.localtime)
    end
  end
end
