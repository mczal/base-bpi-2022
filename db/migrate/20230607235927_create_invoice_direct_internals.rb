class CreateInvoiceDirectInternals < ActiveRecord::Migration[6.1]
  def change
    create_table :invoice_direct_internals, id: :uuid do |t|
      t.timestamps
      t.string "ref_number"
      t.date "date"
      t.string 'description'
    end

    add_reference :invoice_direct_internals, :bank_account, index: true, type: :uuid
    add_foreign_key :invoice_direct_internals, :accounts, column: :bank_account_id
  end
end
