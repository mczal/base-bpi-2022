class CreateAccountMasterBusinessUnits < ActiveRecord::Migration[6.1]
  def change
    create_table :account_master_business_units, id: :uuid do |t|
      t.timestamps
      t.references :account, index: true, foreign_key: true, type: :uuid
      t.references :master_business_unit, index: true, foreign_key: true, type: :uuid
    end
  end
end
