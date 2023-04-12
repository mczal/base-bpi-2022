class CreateRevalLines < ActiveRecord::Migration[6.1]
  def up
    create_table :reval_lines, id: :uuid do |t|
      t.timestamps
      t.string :group
      t.monetize :price_idr
      t.monetize :price_usd
      t.references :reval, index: true, foreign_key: true, type: :uuid
      t.string :description
    end

    add_reference :reval_lines, :account, index: true, type: :uuid
    add_foreign_key :reval_lines, :accounts, column: :account_id

    change_column_default :reval_lines, :price_usd_currency, 'USD'
    change_column_default :reval_lines, :price_idr_currency, 'IDR'
  end

  def down
    drop_table :reval_lines
  end
end
