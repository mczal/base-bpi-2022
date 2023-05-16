class UserNotification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  enum group: {
    waiting_for_approval: 'waiting_for_approval',
    accepted: 'accepted',
    rejected: 'rejected',
  }
end
