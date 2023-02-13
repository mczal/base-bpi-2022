class AddOriginIdToGeneralTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :general_transactions, :origin_id, :string
  end
end
