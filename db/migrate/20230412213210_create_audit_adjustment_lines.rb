class CreateAuditAdjustmentLines < ActiveRecord::Migration[6.1]
  def up
    create_table :audit_adjustment_lines, id: :uuid do |t|
      t.timestamps
      t.string :group
      t.monetize :price_idr
      t.monetize :price_usd
      t.references :audit_adjustment, index: true, foreign_key: true, type: :uuid
      t.string :description
      t.monetize :rate
    end

    add_reference :audit_adjustment_lines, :account, index: true, type: :uuid
    add_foreign_key :audit_adjustment_lines, :accounts, column: :account_id

    change_column_default :audit_adjustment_lines, :price_usd_currency, 'USD'
    change_column_default :audit_adjustment_lines, :price_idr_currency, 'IDR'
    change_column_default :audit_adjustment_lines, :rate_currency, 'IDR'
  end

  def down
    drop_table :audit_adjustment_lines
  end
end
