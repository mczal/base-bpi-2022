module Accounts
  module Reports
    module Balances extend ActiveSupport::Concern
      def balance_idr
        @balance_idr ||= debit_balance_idr - credit_balance_idr
      end
      def debit_balance_idr
        @debit_balance_idr ||= Journal.find_by_sql(
          <<-EOS
            SELECT SUM(debit_idr_cents) as debit_idr_cents, debit_idr_currency
            FROM journals
            WHERE code = '#{self.code}'
            GROUP BY debit_idr_currency
          EOS
        ).first&.debit_idr.to_money
      end
      def credit_balance_idr
        @credit_balance_idr ||= Journal.find_by_sql(
          <<-EOS
            SELECT SUM(credit_idr_cents) as credit_idr_cents, credit_idr_currency
            FROM journals
            WHERE code = '#{self.code}'
            GROUP BY credit_idr_currency
          EOS
        ).first&.credit_idr.to_money
      end

      def balance_usd
        @balance_usd ||= debit_balance_usd - credit_balance_usd
      end
      def debit_balance_usd
        @debit_balance_usd ||= Journal.find_by_sql(
          <<-EOS
            SELECT SUM(debit_usd_cents) as debit_usd_cents, debit_usd_currency
            FROM journals
            WHERE code = '#{self.code}'
            GROUP BY debit_usd_currency
          EOS
        ).first&.debit_usd.to_money.with_currency(:usd)
      end
      def credit_balance_usd
        @credit_balance_usd ||= Journal.find_by_sql(
          <<-EOS
            SELECT SUM(credit_usd_cents) as credit_usd_cents, credit_usd_currency
            FROM journals
            WHERE code = '#{self.code}'
            GROUP BY credit_usd_currency
          EOS
        ).first&.credit_usd.to_money.with_currency(:usd)
      end
    end
  end
end
