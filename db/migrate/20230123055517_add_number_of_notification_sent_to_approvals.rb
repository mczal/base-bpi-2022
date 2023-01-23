class AddNumberOfNotificationSentToApprovals < ActiveRecord::Migration[6.1]
  def change
    add_column :approvals, :number_of_notification_sent, :integer, default: 0
  end
end
