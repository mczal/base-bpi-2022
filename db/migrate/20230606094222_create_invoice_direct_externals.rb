class CreateInvoiceDirectExternals < ActiveRecord::Migration[6.1]
  def up
    create_table :invoice_direct_externals, id: :uuid do |t|
      t.timestamps
      t.string "ref_number"
      t.date "date"
      t.string "receipt_number"
      t.monetize :price
      t.string "ppn_group"
      t.string "status"

      t.boolean "faktur_pajak_checked", default: false
      t.date "tax_receipt_date"
      t.string "tax_receipt_number"
      t.string "ppn_cost_group"
      t.decimal "ppn_percentage"

      t.references :client, index: true, foreign_key: true, type: :uuid
      t.references :bank, index: true, foreign_key: true, type: :uuid
      t.string 'account_number'
      t.string 'account_holder'
      t.string 'description'

      t.string 'location'
    end

    add_reference :invoice_direct_externals, :bank_account, index: true, type: :uuid
    add_foreign_key :invoice_direct_externals, :accounts, column: :bank_account_id

    add_reference :invoice_direct_externals, :cost_center, index: true, type: :uuid
    add_foreign_key :invoice_direct_externals, :accounts, column: :cost_center_id

    add_column :invoice_direct_externals, :is_master_business_units_enabled, :boolean, default: false
    add_reference :invoice_direct_externals, :master_business_unit, index: {name: :ide_mbu}, foreign_key: true, type: :uuid
    add_reference :invoice_direct_externals, :master_business_unit_location, index: {name: :ide_mbul}, foreign_key: {to_table: :master_business_units}, type: :uuid
    add_reference :invoice_direct_externals, :master_business_unit_area, index: {name: :ide_mbuare}, foreign_key: {to_table: :master_business_units}, type: :uuid
    add_reference :invoice_direct_externals, :master_business_unit_activity, index: {name: :ide_mbuact}, foreign_key: {to_table: :master_business_units}, type: :uuid
  end

  def down
    drop_table :invoice_direct_externals
  end
end
