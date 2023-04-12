class CreateRevals < ActiveRecord::Migration[6.1]
  def change
    create_table :revals, id: :uuid do |t|
      t.timestamps
      t.date :date
    end
  end
end
