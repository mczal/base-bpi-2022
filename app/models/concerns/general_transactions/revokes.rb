# frozen_string_literal: true

module GeneralTransactions
  module Revokes extend ActiveSupport::Concern
    def revoke_journals
      return unless self.approvals.present?
      self.journals.destroy_all
    end

    def revoke_all_approvals
      self.approvals.update(status: :waiting)
    end
  end
end
