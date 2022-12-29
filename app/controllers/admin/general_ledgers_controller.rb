module Admin
  class GeneralLedgersController < AdminController
    before_action :presenter, :account_balances_presenter, only: %i[table]

    def index; end

    def table
      render partial: 'table'
    end

    private
      def presenter
        @presenter ||= GeneralLedgersPresenter.new(params)
      end
      def account_balances_presenter
        @account_balances_presenter ||= AccountBalancesPresenter.new(params)
      end
  end
end
