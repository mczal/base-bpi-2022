class CreateAccountCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :account_categories, id: :uuid do |t|
      t.timestamps
      t.string :code
      t.string :description
      t.integer :bottom_treshold
      t.integer :upper_treshold
    end
  end
end
