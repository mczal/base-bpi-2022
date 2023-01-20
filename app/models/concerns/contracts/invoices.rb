# frozen_string_literal: true

module Contracts
  module Invoices extend ActiveSupport::Concern
    def paid_invoices
      invoices.where.not(paid_at: nil)
    end

    def unpaid_invoices
      invoices.where(paid_at: nil)
    end
  end
end
