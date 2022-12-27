module Approvals
  module Helpers extend ActiveSupport::Concern
    def functioned_approvals
      self.approvals
    end

    def synchronize_status_after_approval
      approval_statuses = functioned_approvals.pluck(:status)
      return if !approval_statuses.all? "accepted"

      accepted!
    end
  end
end

