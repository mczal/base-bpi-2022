class AddIndexOnCodeToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_index :accounts, :code
  end
end
