class AddDebitUsdAndCreditUsdToJournals < ActiveRecord::Migration[6.1]
  def change
    add_monetize :journals, :debit_usd
    add_monetize :journals, :credit_usd

    change_column_default :journals, :debit_usd_currency, 'USD'
    change_column_default :journals, :credit_usd_currency, 'USD'
  end
end
