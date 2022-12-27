class CreateApprovals < ActiveRecord::Migration[6.1]
  def change
    create_table :approvals, id: :uuid do |t|
      t.timestamps
      t.string :status
      # t.string :user_id
      t.references :user, index: true, foreign_key: true, type: :uuid
      t.string :role
      t.integer :order, index: true
      t.string :name
      t.references :approvable, polymorphic: true, null:false, type: :uuid
    end
  end
end
