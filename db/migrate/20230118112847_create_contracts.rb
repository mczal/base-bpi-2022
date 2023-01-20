class CreateContracts < ActiveRecord::Migration[6.1]
  def change
    create_table :contracts, id: :uuid do |t|
      t.timestamps
      t.date 'started_at'
      t.date 'ended_at'
      t.string 'ref_number'

      t.monetize :price
      # t.decimal 'price_cents', default: '0.0', null: false
      # t.string 'price_currency', default: 'IDR', null: false

      t.string 'status', index: true

      t.references :client, index: true, foreign_key: true, type: :uuid
      t.references :bank, index: true, foreign_key: true, type: :uuid

      t.string 'account_number'
      t.string 'account_holder'
      t.string 'description'
      t.string 'started_with_group'
      t.string 'started_with_ref_number'
      t.date 'started_with_date'
      t.integer 'time_period'
      t.integer 'payment_time_period'
      t.string 'payment_time_period_group'
    end

    add_reference :contracts, :accrued_debit, index: true, type: :uuid
    add_foreign_key :contracts, :accounts, column: :accrued_debit_id
  end
end
