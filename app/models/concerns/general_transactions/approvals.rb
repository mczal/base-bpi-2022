# frozen_string_literal: true

module GeneralTransactions
  module Approvals extend ActiveSupport::Concern
    def approval_lines
      return @approval_lines if @approval_lines.present?

      @approval_lines = []
      # @approval_lines << {
        # name: 'Manager Keuangan dan Anggaran',
        # role: "manager_finance"
      # }
      # @approval_lines << {
        # name: 'Direktur Keuangan dan Umum',
        # role: "director_finance"
      # }

      if self.ba? || self.invoice_approved?
        @approval_lines << {
          name: 'Manager Keuangan dan Anggaran',
          role: "manager_finance"
        }
        @approval_lines << {
          name: 'Manager Akunting',
          role: "manager_accounting"
        }
        return @approval_lines
      end

      # BEGIN: COMMENTED PER 31 Jul 2024. Phase manual input based from client's request
      # ac_1 = ApprovalConfiguration.find_by(bottom_treshold_cents: 0, upper_treshold_cents: 0)
      # ac_1.roles.each do |x|
        # @approval_lines << {
          # name: x.titlecase,
          # role: x
        # }
      # end

      # total_debit = self.general_transaction_lines.filter(&:debit?).sum(&:price_idr)
      # total_credit = self.general_transaction_lines.filter(&:credit?).sum(&:price_idr)
      # max_value = [total_debit,total_credit].max

      # acs = ApprovalConfiguration.where.not(id: ac_1.id).filter{|x|x.bottom_treshold < max_value}
      # acs.each do |ac|
        # ac.roles.each do |y|
          # @approval_lines << {
            # name: y.titlecase,
            # role: y
          # }
        # end
      # end
      # END: COMMENTED PER 31 Jul 2024. Phase manual input based from client's request

      # BEGIN: COMMENTED PER 16 Aug 2024. Phase manual input based from clien's request #2
      # if self.number_evidence.match(/bj/i)
        # @approval_lines << {
          # name: 'manager_finance'.titlecase,
          # role: 'manager_finance',
        # }
        # @approval_lines << {
          # name: 'evp_finance'.titlecase,
          # role: 'evp_finance',
        # }
      # else # BNI, BM, *ETC.
        # @approval_lines << {
          # name: 'manager_finance'.titlecase,
          # role: 'manager_finance',
        # }
      # end
      # END: COMMENTED PER 16 Aug 2024. Phase manual input based from clien's request #2

      @approval_lines << {
        name: 'manager_finance'.titlecase,
        role: 'manager_finance',
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
      if approval_statuses.include?('rejected')
        rejected!
        return
      end
      if approval_statuses.include?('waiting')
        waiting_for_approval!
        return
      end
      if approval_statuses.all?("accepted")
        accepted!
        general_transaction_lines.each do |line|
          line.setup_journals
        end
        if self.invoice_approved?
          self.transactionable.approved!
        end
        if self.invoice_direct_external_paid?
          self.transactionable.paid!
        end
      end
    end
  end
end
