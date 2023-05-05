class AddStatusToRevals < ActiveRecord::Migration[6.1]
  def change
    add_column :revals, :status, :string
  end
end
