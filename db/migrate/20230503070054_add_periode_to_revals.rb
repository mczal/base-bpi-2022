class AddPeriodeToRevals < ActiveRecord::Migration[6.1]
  def change
    add_column :revals, :period, :string
  end
end
