class AddPeriodeToRevals < ActiveRecord::Migration[6.1]
  def change
    add_column :revals, :periode, :string
  end
end
