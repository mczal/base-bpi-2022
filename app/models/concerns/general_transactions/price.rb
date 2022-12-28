# frozen_string_literal: true

module GeneralTransactions
  module Price extend ActiveSupport::Concern
    def total_debit_idr
      @total_debit_idr ||= general_transaction_lines.debit.sum(&:idr).to_money
    end
    def total_debit_usd
      @total_debit_usd ||= general_transaction_lines.debit.sum(&:usd).to_money.with_currency(:usd)
    end

    def total_credit_idr
      @total_credit_idr ||= general_transaction_lines.credit.sum(&:idr).to_money
    end
    def total_credit_usd
      @total_credit_usd ||= general_transaction_lines.credit.sum(&:usd).to_money.with_currency(:usd)
    end

    def idr_balance_check
      @idr_balance_check ||= (total_debit_idr - total_credit_idr)
    end
    def usd_balance_check
      @usd_balance_check ||= (total_debit_usd - total_credit_usd)
    end
  end
end
