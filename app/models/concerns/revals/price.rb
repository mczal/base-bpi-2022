module Revals
  module Price extend ActiveSupport::Concern
    def total_debit_idr
      @total_debit_idr ||= reval_lines.debit.sum(&:price_idr).to_money
    end
    def total_debit_usd
      @total_debit_usd ||= reval_lines.debit.sum(&:price_usd).to_money.with_currency(:usd)
    end
    def total_credit_idr
      @total_credit_idr ||= reval_lines.credit.sum(&:price_idr).to_money
    end
    def total_credit_usd
      @total_credit_usd ||= reval_lines.credit.sum(&:price_usd).to_money.with_currency(:usd)
    end
    def idr_balance_check
      @idr_balance_check ||= (total_debit_idr - total_credit_idr)
    end
    def usd_balance_check
      @usd_balance_check ||= (total_debit_usd - total_credit_usd)
    end
  end
end
