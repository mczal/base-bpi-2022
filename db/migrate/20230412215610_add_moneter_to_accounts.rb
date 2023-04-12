class AddMoneterToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :moneter, :boolean, default: false
  end
end
