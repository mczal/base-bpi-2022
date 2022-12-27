# frozen_string_literal: true

module GeneralTransactions
  class BaseService < ::BaseService
    def initialize(params, company_id)
      @params = params
      @company_id = company_id
    end

    protected

    def general_transaction_params
      @general_transaction_params ||= @params.require(:transaction).permit(:id, :date, :number_evidence)
    end

    def general_transaction_lines_params
      debit_params = @params.require(:general_transaction_line_debit).values
      credit_params = @params.require(:general_transaction_line_credit).values
      @general_transaction_lines_params ||= debit_params + credit_params
    end
  end
end
