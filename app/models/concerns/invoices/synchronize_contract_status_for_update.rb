# frozen_string_literal: true

module Invoices
  module SynchronizeContractStatusForUpdate
    extend ActiveSupport::Concern
    included do
      after_save :synchronize_to_contract
      after_destroy :synchronize_to_contract
    end

    def synchronize_to_contract
      return unless contract.present?

      contract.refresh_status!
    end
  end
end
