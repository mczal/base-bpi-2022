class AddSourceToGeneralTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :general_transactions, :source, :string
  end
end
