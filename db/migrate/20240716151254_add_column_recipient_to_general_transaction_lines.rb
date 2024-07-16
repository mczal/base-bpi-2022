class AddColumnRecipientToGeneralTransactionLines < ActiveRecord::Migration[6.1]
  def change
    add_column :general_transaction_lines, :recipient, :string
  end
end
