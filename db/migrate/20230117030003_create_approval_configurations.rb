class CreateApprovalConfigurations < ActiveRecord::Migration[6.1]
  def change
    create_table :approval_configurations, id: :uuid do |t|
      t.timestamps
      t.string :roles, array: true, default: []
      t.monetize :bottom_treshold
      t.monetize :upper_treshold
    end
  end
end
