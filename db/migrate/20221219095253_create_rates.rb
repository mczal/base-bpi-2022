class CreateRates < ActiveRecord::Migration[6.1]
  def change
    create_table :rates, id: :uuid do |t|
      t.timestamps
      t.monetize :buying
      t.monetize :selling
      t.string :origin
      t.date :published_date
    end
  end
end
