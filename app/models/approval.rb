# == Schema Information
#
# Table name: approvals
#
#  id                          :uuid             not null, primary key
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  status                      :string
#  user_id                     :uuid
#  role                        :string
#  order                       :integer
#  name                        :string
#  approvable_type             :string           not null
#  approvable_id               :uuid             not null
#  number_of_notification_sent :integer          default(0)
#
class Approval < ApplicationRecord
  audited
  include Approvals::StatusLabel
  include Approvals::Siblings
  include Approvals::AssignDefaultValues
  include Audited::Logs

  belongs_to :approvable, polymorphic: true
  belongs_to :user, optional: true

  after_save :synchronize_to_approvable

  enum status: {
    waiting: "waiting",
    rejected: "rejected",
    accepted: "accepted"
  }

  enum approvable_type: {
    GeneralTransaction: "GeneralTransaction",
  }

  def approver
    approvers.first
  end

  def approvers
    User
      .with_role(self.role)
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
