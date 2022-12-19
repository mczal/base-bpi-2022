class RemoveSubclassificationInAccounts < ActiveRecord::Migration[6.1]
  def change
    remove_column :accounts, :subclassification
    remove_column :accounts, :subclassification_en
  end
end
