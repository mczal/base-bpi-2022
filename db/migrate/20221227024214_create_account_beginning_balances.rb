class CreateAccountBeginningBalances < ActiveRecord::Migration[6.1]
  def change
    create_table :account_beginning_balances, id: :uuid do |t|
      t.timestamps
      t.string :code
      t.monetize :price_idr
      t.monetize :price_usd
      t.integer :year
    end

    change_column_default :account_beginning_balances, :price_usd_currency, 'USD'
  end
end
