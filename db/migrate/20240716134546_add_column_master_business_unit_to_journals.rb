class AddColumnMasterBusinessUnitToJournals < ActiveRecord::Migration[6.1]
  def change
    add_column :journals, :master_business_unit, :string
  end
end
