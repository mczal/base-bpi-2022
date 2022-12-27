class AddMasterBusinessUnitToGeneralTransactionLines < ActiveRecord::Migration[6.1]
  def change
    add_reference :general_transaction_lines, :master_business_unit, index: {name: :gtl_mbu}, foreign_key: true, type: :uuid
    add_reference :general_transaction_lines, :master_business_unit_location, index: {name: :gtl_mbul}, foreign_key: {to_table: :master_business_units}, type: :uuid
    add_reference :general_transaction_lines, :master_business_unit_area, index: {name: :gtl_mbuare}, foreign_key: {to_table: :master_business_units}, type: :uuid
    add_reference :general_transaction_lines, :master_business_unit_activity, index: {name: :gtl_mbuact}, foreign_key: {to_table: :master_business_units}, type: :uuid
  end
end
