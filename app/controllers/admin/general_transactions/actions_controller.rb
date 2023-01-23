module Admin
  module GeneralTransactions
    class ActionsController < ::Admin::ApplicationController
      def get_number_evidence
        render json: {
          result_cash: ::GeneralTransaction.retrieve_new_number_evidence(
            params[:location],
            :cash,
            cash_account: cash_account
          ),
          result_bj: ::GeneralTransaction.retrieve_new_number_evidence(
            params[:location],
            :bj,
            cash_account: cash_account
          )
        }
      end

      private
        def cash_account
          @cash_account ||= Account.find_by(id: params[:cash_account_id])
        end
    end
  end
end
