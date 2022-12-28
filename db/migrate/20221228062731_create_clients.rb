class CreateClients < ActiveRecord::Migration[6.1]
  def change
    create_table :clients, id: :uuid do |t|
      t.timestamps
      t.string "name"
      t.string "email"
      t.string "phone_number"
      t.text "address"

      t.string "npwp"

      t.string "account_bank"
      t.string "account_number"
      t.string "account_name"

      t.string "group"
      t.string "pkp_group"

      t.references :bank, index: true, foreign_key: true, type: :uuid
      t.references :company, index: true, foreign_key: true, type: :uuid
    end
  end
end
