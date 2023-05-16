module Users
  module ApprovalAsNotifications extend ActiveSupport::Concern
    def notification_from_approvals
      # ambil yang belum di approve
      # ambil yang sudah di approve 3 hari terakhir

      @notification_from_approvals ||= Approval.waiting
        .or(Approval.rejected)
        .or(Approval.accepted.where(updated_at: 3.days.before..DateTime.now ))
        .reorder(updated_at: :desc)
    end
  end
end
