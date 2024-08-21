# frozen_string_literal: true

module GeneralTransactionLines
  module Price extend ActiveSupport::Concern
    def idr
      if self.rate == 0
        return price_idr.to_money
      end

      if self.general_transaction.idr? || self.general_transaction.no_automatic_rates_adjustment? # input_option
        return price_idr.to_money
      end
      return (price_usd.to_money * self.general_transaction.rate_money.amount).with_currency(:idr)
    end

    def usd
      if !self.general_transaction.rate_instance.present?
        return price_usd.to_money
      end

      if self.general_transaction.usd? || self.general_transaction.no_automatic_rates_adjustment? # input_option
        return price_usd.to_money
      end
      return (price_idr.to_money / self.general_transaction.rate_money.amount).with_currency(:usd)
    end
  end
end
