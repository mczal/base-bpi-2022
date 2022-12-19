class RemoveAccountTypeInAccounts < ActiveRecord::Migration[6.1]
  def change
    remove_column :accounts, :account_type
  end
end
