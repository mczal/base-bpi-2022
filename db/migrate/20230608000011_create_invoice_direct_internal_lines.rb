class CreateInvoiceDirectInternalLines < ActiveRecord::Migration[6.1]
  def up
    create_table :invoice_direct_internal_lines, id: :uuid do |t|
      t.timestamps
      t.references :invoice_direct_internal, index: {name: :idi_idil}, foreign_key: true, type: :uuid
      t.string :name
      t.monetize :price
      t.string 'location'
    end

    add_reference :invoice_direct_internal_lines, :cost_center, index: true, type: :uuid
    add_foreign_key :invoice_direct_internal_lines, :accounts, column: :cost_center_id

    add_column :invoice_direct_internal_lines, :is_master_business_units_enabled, :boolean, default: false
    add_reference :invoice_direct_internal_lines, :master_business_unit, index: {name: :idi_mbu}, foreign_key: true, type: :uuid
    add_reference :invoice_direct_internal_lines, :master_business_unit_location, index: {name: :idi_mbul}, foreign_key: {to_table: :master_business_units}, type: :uuid
    add_reference :invoice_direct_internal_lines, :master_business_unit_area, index: {name: :idi_mbuare}, foreign_key: {to_table: :master_business_units}, type: :uuid
    add_reference :invoice_direct_internal_lines, :master_business_unit_activity, index: {name: :idi_mbuact}, foreign_key: {to_table: :master_business_units}, type: :uuid
  end

  def down
    drop_table :invoice_direct_internal_lines
  end
end
