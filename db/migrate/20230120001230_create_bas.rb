class CreateBas < ActiveRecord::Migration[6.1]
  def change
    create_table :bas, id: :uuid do |t|
      t.timestamps
      t.references :contract, index: true, foreign_key: true, type: :uuid
      t.text "description"
      t.string "reference_number"
      t.date "date"
      t.date "levered_at"
      t.date "realized_at"
      t.integer "_number_of_days_late"
      t.string "status"
      t.monetize :price
    end

    add_reference :bas, :accrued_credit, index: true, type: :uuid
    add_foreign_key :bas, :accounts, column: :accrued_credit_id
  end
end
