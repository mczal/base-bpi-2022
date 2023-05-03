module Revals
  class UpdateAccountConfigurationService < ::BaseService
    def initialize params
      @params = params
    end

    private
      def action
        accounts.update(moneter: true)
        accounts_to_be_removed.update(moneter: false)
      end

      def accounts
        @accounts ||= Account.where(id: account_ids)
      end
      def accounts_to_be_removed
        @accounts_to_be_removed ||= Account.moneter.where.not(id: account_ids)
      end

      def account_ids
        @account_ids ||= @params[:account_id]
      end
  end
end
