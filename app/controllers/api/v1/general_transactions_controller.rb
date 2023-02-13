module Api
  module V1
    class GeneralTransactionsController < Api::ApplicationController
      include Api::Authorizable
      skip_before_action :verify_authenticity_token
      before_action :decrypted_data

      def create
        service = ::GeneralTransactions::CreateService.new(
          ActionController::Parameters.new(decrypted_data),
          Company.bpi
        )
        if !service.run
          return render json: {
            message: "Gagal. #{service.full_error_messages}"
          }, status: :bad_request
        end

        return render json: {
          message: "Berhasil!",
          general_transaction: {
            id: service.general_transaction.id,
          }
        }
      end
    end
  end
end
