class AddTransactionableToGeneralTransactions < ActiveRecord::Migration[6.1]
  def change
    add_reference :general_transactions, :transactionable, polymorphic: true, index: true, type: :uuid
  end
end
