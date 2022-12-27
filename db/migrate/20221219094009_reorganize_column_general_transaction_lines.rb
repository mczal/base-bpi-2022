class ReorganizeColumnGeneralTransactionLines < ActiveRecord::Migration[6.1]
  def change
    remove_column :general_transaction_lines, :debit_idr_cents
    remove_column :general_transaction_lines, :debit_idr_currency
    remove_column :general_transaction_lines, :credit_idr_cents
    remove_column :general_transaction_lines, :credit_idr_currency

    add_monetize :general_transaction_lines, :price_idr
    add_monetize :general_transaction_lines, :price_usd
    add_column :general_transaction_lines, :group, :string
  end
end
