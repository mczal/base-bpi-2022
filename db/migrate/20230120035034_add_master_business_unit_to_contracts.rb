class AddMasterBusinessUnitToContracts < ActiveRecord::Migration[6.1]
  def change
    add_column :contracts, :is_master_business_units_enabled, :boolean, default: false
    add_reference :contracts, :master_business_unit, index: {name: :contract_mbu}, foreign_key: true, type: :uuid
    add_reference :contracts, :master_business_unit_location, index: {name: :contract_mbul}, foreign_key: {to_table: :master_business_units}, type: :uuid
    add_reference :contracts, :master_business_unit_area, index: {name: :contract_mbuare}, foreign_key: {to_table: :master_business_units}, type: :uuid
    add_reference :contracts, :master_business_unit_activity, index: {name: :contract_mbuact}, foreign_key: {to_table: :master_business_units}, type: :uuid
  end
end
