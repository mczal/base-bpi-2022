class AddLocationToJournals < ActiveRecord::Migration[6.1]
  def change
    add_column :journals, :location, :string
  end
end
