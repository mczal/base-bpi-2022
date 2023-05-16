class Approval < ApplicationRecord
  audited
  include Approvals::StatusLabel
  include Approvals::Siblings
  include Approvals::AssignDefaultValues
  include Approvals::NotificationText
  include Audited::Logs

  belongs_to :approvable, polymorphic: true
  belongs_to :user, optional: true
  has_many :user_notifications, as: :notifiable, dependent: :destroy

  after_save :synchronize_to_approvable

  enum status: {
    waiting: "waiting",
    rejected: "rejected",
    accepted: "accepted"
  }

  enum approvable_type: {
    GeneralTransaction: "GeneralTransaction",
    Reval: "Reval",
    AuditAdjustment: "AuditAdjustment",
  }

  default_scope { order(order: :asc) }

  def approver
    approvers.first
  end

  def approvers
    User.with_role(self.role)
  end

  def pre_approvals
    self.approvable.approvals.where('approvals.order < ?', self.order)
  end

  def synchronize_to_approvable
    return unless approvable.present?
    approvable.synchronize_status_after_approval
  end

  def approvable_color
    "warning"
  end
end
