class AddRatesValueInGeneralTransactionLines < ActiveRecord::Migration[6.1]
  def change
    add_monetize :general_transaction_lines, :rate
  end
end
