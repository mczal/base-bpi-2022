class CreateAddendums < ActiveRecord::Migration[6.1]
  def change
    create_table :addendums, id: :uuid do |t|
      t.timestamps
      t.string "ref_number"
      t.references :contract, index: true, foreign_key: true, type: :uuid
      t.json "contract_changes"
      t.date "date"
      t.text "description"
    end
  end
end
