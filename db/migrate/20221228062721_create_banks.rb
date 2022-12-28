class CreateBanks < ActiveRecord::Migration[6.1]
  def change
    create_table :banks, id: :uuid do |t|
      t.timestamps
      t.string "name"
      t.string "code"
    end
  end
end
