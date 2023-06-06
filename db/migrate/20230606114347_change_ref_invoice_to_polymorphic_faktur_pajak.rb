class ChangeRefInvoiceToPolymorphicFakturPajak < ActiveRecord::Migration[6.1]
  def up
    remove_column :faktur_pajaks, :invoice_id
    add_reference :faktur_pajaks, :faktur_pajakable, polymorphic: true, index: true, type: :uuid
  end

  def down
    add_reference :faktur_pajaks, :invoice, index: true, foreign_key: true, type: :uuid
    remove_column :faktur_pajaks, :faktur_pajakable_type
    remove_column :faktur_pajaks, :faktur_pajakable_id
  end
end
