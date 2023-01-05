class AddGroupToReports < ActiveRecord::Migration[6.1]
  def change
    add_column :reports, :group, :string
  end
end
