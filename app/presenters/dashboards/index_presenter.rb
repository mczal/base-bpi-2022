module Dashboards
  class IndexPresenter < BasePresenter
    include Dashboards::Helpers::CashBalancePresenter
    include Dashboards::Helpers::BankAccountsPresenter
    include Dashboards::Helpers::CashInOutPresenter
    include Dashboards::Helpers::ProfitLossPresenter

    def initialize start_date, end_date, current_company
      @params_start_date = start_date
      @params_end_date = end_date
      @current_company = current_company

      # set_data_cash_balances
      # set_data_bank_accounts
      # set_data_cash_in_out
      # set_data_profit_loss
    end

  end
end
