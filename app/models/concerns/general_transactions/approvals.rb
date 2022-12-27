# frozen_string_literal: true

module GeneralTransactions
  module Approvals extend ActiveSupport::Concern
    def approval_lines
      @approval_lines = []
      @approval_lines << {
        name: 'Manager Keuangan dan Anggaran',
        role: "manager_finance"
      }
      @approval_lines << {
        name: 'Direktur Keuangan dan Umum',
        role: "director_finance"
      }
      return @approval_lines
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
      general_transaction_lines.each do |line|
        line.setup_journals
      end
    end
  end
end
