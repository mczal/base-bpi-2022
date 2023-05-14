class CreateUserNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :user_notifications, id: :uuid do |t|
      t.timestamps
      t.references :user, index: true, foreign_key: true, type: :uuid
      t.references :notifiable, polymorphic: true, null: false, type: :uuid
      t.string :group
      t.string :title
      t.string :source_path
      t.datetime :read_at
    end
  end
end
