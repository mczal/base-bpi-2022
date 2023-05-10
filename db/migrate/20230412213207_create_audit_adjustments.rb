class CreateAuditAdjustments < ActiveRecord::Migration[6.1]
  def change
    create_table :audit_adjustments, id: :uuid do |t|
      t.timestamps
      t.date :date
      t.string :period
      t.string :status
      t.string :number_evidence
    end
  end
end
