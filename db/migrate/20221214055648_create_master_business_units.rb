class CreateMasterBusinessUnits < ActiveRecord::Migration[6.1]
  def change
    create_table :master_business_units, id: :uuid do |t|
      t.timestamps
      t.string :code
      t.text :description
      t.string :group
    end
  end
end
