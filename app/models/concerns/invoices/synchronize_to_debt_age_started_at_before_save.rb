# frozen_string_literal: true

module Invoices
  module SynchronizeToDebtAgeStartedAtBeforeSave extend ActiveSupport::Concern
    included do
      before_save :synchronize_to_debt_age_started_at_before_save
    end

    def synchronize_to_debt_age_started_at_before_save
      if self.status_change.present? && self.status_change[1] == 'approved'
        self.debt_age_started_at = DateTime.now.localtime.to_date
        return
      end
      if self.status_change.present? && !%w(approved paid).include?(self.status_change[1])
        self.debt_age_started_at = nil
        return
      end
    end
  end
end
