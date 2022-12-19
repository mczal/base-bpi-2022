class AddIsak16NonIsakFiskalToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :isak_16, :boolean, default: false
    add_column :accounts, :non_isak, :boolean, default: false
    add_column :accounts, :fiskal, :boolean, default: false
  end
end
