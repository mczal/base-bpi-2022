class AddReferenceAccountToAccountCategories < ActiveRecord::Migration[6.1]
  def change
    add_reference :accounts, :account_category, index: true, foreign_key: true, type: :uuid
  end
end
