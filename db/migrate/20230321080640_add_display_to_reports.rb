class AddDisplayToReports < ActiveRecord::Migration[6.1]
  def change
    add_column :reports, :display, :string, default: 'html'
  end
end
