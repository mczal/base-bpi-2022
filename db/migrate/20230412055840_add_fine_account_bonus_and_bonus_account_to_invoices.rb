class AddFineAccountBonusAndBonusAccountToInvoices < ActiveRecord::Migration[6.1]
  def up
    add_reference :invoices, :fine_account, index: true, type: :uuid
    add_foreign_key :invoices, :accounts, column: :fine_account_id

    add_monetize :invoices, :bonus
    add_reference :invoices, :bonus_account, index: true, type: :uuid
    add_foreign_key :invoices, :accounts, column: :bonus_account_id
  end

  def down
    remove_column :invoices, :fine_account_id
    remove_column :invoices, :bonus_account_id

    remove_column :invoices, :bonus_cents
    remove_column :invoices, :bonus_currency
  end
end
