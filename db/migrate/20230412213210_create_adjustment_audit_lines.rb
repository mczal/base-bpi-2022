class CreateAdjustmentAuditLines < ActiveRecord::Migration[6.1]
  def up
    create_table :adjustment_audit_lines, id: :uuid do |t|
      t.string :group
      t.monetize :price_idr
      t.monetize :price_usd
      t.string :description
      t.timestamps
    end

    add_reference :adjustment_audit_lines, :account, index: true, type: :uuid
    add_foreign_key :adjustment_audit_lines, :accounts, column: :account_id

    change_column_default :adjustment_audit_lines, :price_usd_currency, 'USD'
    change_column_default :adjustment_audit_lines, :price_idr_currency, 'IDR'
  end

  def down
    drop_table :adjustment_audit_lines
  end
end
