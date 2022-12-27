class AddStatusToGeneralTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :general_transactions, :status, :string
  end
end
