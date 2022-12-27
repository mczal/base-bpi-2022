class UpdateDefaultCurrencyToUsdInGeneralTransactionLineForPriceUsd < ActiveRecord::Migration[6.1]
  def change
    change_column_default :general_transaction_lines, :price_usd_currency, 'USD'
  end
end
