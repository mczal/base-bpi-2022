# frozen_string_literal: true

module AuditAdjustments
  module Approvals extend ActiveSupport::Concern
    def approval_lines
      return @approval_lines if @approval_lines.present?
      @approval_lines = []
      @approval_lines << {
        name: 'Manager Keuangan dan Anggaran',
        role: "manager_finance"
      }
      @approval_lines << {
        name: 'Manager Akunting',
        role: "manager_accounting"
      }
      @approval_lines
    end

    def printed_approvals
      self.approvals
    end

    def functioned_approvals
      self.approvals
    end

    def synchronize_status_after_approval
      approval_statuses = functioned_approvals.pluck(:status)
      return if !approval_statuses.all? "accepted"

      accepted!
      audit_adjustment_lines.each do |line|
        line.setup_journals
      end
    end
  end
end
