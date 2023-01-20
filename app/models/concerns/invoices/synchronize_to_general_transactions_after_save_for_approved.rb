# frozen_string_literal: true

module Invoices
  module SynchronizeToGeneralTransactionsAfterSaveForApproved extend ActiveSupport::Concern
    included do
      after_save :synchronize_to_general_transactions_after_save_for_approved
    end

    def synchronize_to_general_transactions_after_save_for_approved
      return unless approved?
    end

    def fine_reduction
    end
  end
end
