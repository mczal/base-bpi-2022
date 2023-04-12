class CreateAdjustmentAudits < ActiveRecord::Migration[6.1]
  def change
    create_table :adjustment_audits, id: :uuid do |t|
      t.timestamps
      t.date :date
    end
  end
end
