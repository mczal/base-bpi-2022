# frozen_string_literal: true

module Invoices
  module Approvals extend ActiveSupport::Concern
    included do
      after_create :generate_approvals
    end

    def generate_approvals
      approval_lines.each.with_index(1) do |approval, i|
        approval = Approval.find_or_initialize_by(
          approvable: self,
          name: approval[:name],
          role: approval[:role],
          order: i
        )
        approval.save! if approval.new_record?
      end
    end

    def approval_lines
      @approval_lines = []
      @approval_lines << {
        name: 'Manager Keuangan dan Anggaran',
        role: "manager_finance"
      }
      @approval_lines << {
        name: 'EVP Keuangan',
        role: "evp_finance"
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
  end
end
