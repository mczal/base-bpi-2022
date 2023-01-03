class CreateReportReferences < ActiveRecord::Migration[6.1]
  def change
    create_table :report_references, id: :uuid do |t|
      t.timestamps
      t.references :report, index: true, foreign_key: true, type: :uuid
      t.string :account_code
      t.string :account_name
      t.string :reference_code
    end
  end
end
