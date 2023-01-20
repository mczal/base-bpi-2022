# frozen_string_literal: true

module GeneralTransactions
  module Approvals extend ActiveSupport::Concern
    def approval_lines
      @approval_lines = []
      # @approval_lines << {
        # name: 'Manager Keuangan dan Anggaran',
        # role: "manager_finance"
      # }
      # @approval_lines << {
        # name: 'Direktur Keuangan dan Umum',
        # role: "director_finance"
      # }

      ac_1 = ApprovalConfiguration.find_by(bottom_treshold_cents: 0, upper_treshold_cents: 0)
      ac_1.roles.each do |x|
        @approval_lines << {
          name: x.titlecase,
          role: x
        }
      end

      total_debit = self.general_transaction_lines.debit.sum(&:price_idr)
      total_credit = self.general_transaction_lines.credit.sum(&:price_idr)
      max_value = [total_debit,total_credit].max

      acs = ApprovalConfiguration.where.not(id: ac_1.id).filter{|x|x.bottom_treshold < max_value}
      acs.each do |ac|
        ac.roles.each do |y|
          @approval_lines << {
            name: y.titlecase,
            role: y
          }
        end
      end

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
      general_transaction_lines.each do |line|
        line.setup_journals
      end
    end
  end
end
