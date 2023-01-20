class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices, id: :uuid do |t|
      t.timestamps
      t.string "spp_number"
      t.string "ref_number"
      t.date "date"
      t.string "receipt_number"
      t.monetize :price
      t.string "ppn_group"
      t.date "tax_receipt_date"
      t.string "tax_receipt_number"
      t.references :invoiceable, polymorphic: true, index: true, type: :uuid
      t.string "status"
      t.string "ppn_cost_group"

      t.decimal "pph_percentage"
      t.monetize :fine
      t.date "debt_age_started_at"
      t.decimal "ppn_percentage"

      t.boolean "spp_checked", default: false
      t.boolean "invoice_checked", default: false
      t.boolean "kwitansi_checked", default: false
      t.boolean "faktur_pajak_checked", default: false
      t.datetime "received_at"
    end

    add_reference :invoices, :pph, index: true, type: :uuid
    add_foreign_key :invoices, :accounts, column: :pph_id

    add_reference :invoices, :accrued_credit, index: true, type: :uuid
    add_foreign_key :invoices, :accounts, column: :accrued_credit_id

    add_reference :invoices, :bank_account, index: true, type: :uuid
    add_foreign_key :invoices, :accounts, column: :bank_account_id
  end
end
