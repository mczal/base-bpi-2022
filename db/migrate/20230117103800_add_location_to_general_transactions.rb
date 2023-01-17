class AddLocationToGeneralTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :general_transactions, :location, :string
  end
end
