class AddLocationToContracts < ActiveRecord::Migration[6.1]
  def change
    add_column :contracts, :location, :string
  end
end
