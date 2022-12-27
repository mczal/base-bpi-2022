class AddIsMasterBusinessUnitEnabledToGeneralTransactionLines < ActiveRecord::Migration[6.1]
  def change
    add_column :general_transaction_lines, :is_master_business_units_enabled, :boolean, default: false
  end
end
