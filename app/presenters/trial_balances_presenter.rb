class TrialBalancesPresenter
  def initialize params
    @params = params
  end

  def balance account:
    @balance = {
      date: daterange.first,
      balance_idr: 0.to_money,
      balance_usd: 0.to_money.with_currency(:usd),
    }
    append_beginning_balance_in_current_year account
    append_balance_from_journals account

    @balance
  end

  private
    def append_beginning_balance_in_current_year account
      account_beginning_balance = AccountBeginningBalance.find_by(
        code: account.code,
        year: daterange.first.year
      )
      return unless account_beginning_balance.present?

      @balance[:balance_idr] += account_beginning_balance.price_idr
      @balance[:balance_usd] += account_beginning_balance.price_usd
    end

    def append_balance_from_journals account
      @balance[:balance_idr] += begin_balance_idr(account)
      @balance[:balance_usd] += begin_balance_usd(account)
    end

    def begin_balance_idr account
      @begin_balance_idr = begin_debit_balance_idr(account) - begin_credit_balance_idr(account)
    end
    def begin_debit_balance_idr account
      @begin_debit_balance_idr = Journal.find_by_sql(
        <<-EOS
          SELECT SUM(debit_idr_cents) as debit_idr_cents, debit_idr_currency
          FROM journals
          WHERE code = '#{account.code}' AND
            date <= '#{daterange.last}' AND
            date >= '#{daterange.first.beginning_of_year}'
          GROUP BY debit_idr_currency
        EOS
      ).first&.debit_idr.to_money
    end
    def begin_credit_balance_idr account
      @begin_credit_balance_idr = Journal.find_by_sql(
        <<-EOS
          SELECT SUM(credit_idr_cents) as credit_idr_cents, credit_idr_currency
          FROM journals
          WHERE code = '#{account.code}' AND
            date <= '#{daterange.last}' AND
            date >= '#{daterange.first.beginning_of_year}'
          GROUP BY credit_idr_currency
        EOS
      ).first&.credit_idr.to_money
    end

    def begin_balance_usd account
      @begin_balance_usd = begin_debit_balance_usd(account) - begin_credit_balance_usd(account)
    end
    def begin_debit_balance_usd account
      @begin_debit_balance_usd = Journal.find_by_sql(
        <<-EOS
          SELECT SUM(debit_usd_cents) as debit_usd_cents, debit_usd_currency
          FROM journals
          WHERE code = '#{account.code}' AND
            date <= '#{daterange.last}' AND
            date >= '#{daterange.first.beginning_of_year}'
          GROUP BY debit_usd_currency
        EOS
      ).first&.debit_usd.to_money.with_currency(:usd)
    end
    def begin_credit_balance_usd account
      @begin_credit_balance_usd = Journal.find_by_sql(
        <<-EOS
          SELECT SUM(credit_usd_cents) as credit_usd_cents, credit_usd_currency
          FROM journals
          WHERE code = '#{account.code}' AND
            date <= '#{daterange.last}' AND
            date >= '#{daterange.first.beginning_of_year}'
          GROUP BY credit_usd_currency
        EOS
      ).first&.credit_usd.to_money.with_currency(:usd)
    end

    def daterange
      return @daterange if @daterange.present?

      token = @params[:daterange].split('-')
      start_date = Date.strptime(token[0], '%d/%m/%Y')
      end_date = Date.strptime(token[1], '%d/%m/%Y')

      @daterange = start_date..end_date
    end
end
