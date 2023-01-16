class CreateReportLines < ActiveRecord::Migration[6.1]
  def change
    create_table :report_lines, id: :uuid do |t|
      t.string :name
      t.integer :order
      t.string :codes, array: true, default: []
      t.string :formula
      t.string :group
      t.references :report, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
