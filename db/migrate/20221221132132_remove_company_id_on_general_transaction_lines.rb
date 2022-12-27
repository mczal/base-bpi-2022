class RemoveCompanyIdOnGeneralTransactionLines < ActiveRecord::Migration[6.1]
  def change
    remove_column :general_transaction_lines, :company_id
  end
end
