# frozen_string_literal: true

module InvoiceDirectInternals
  module Prices extend ActiveSupport::Concern
    def total_price
      @total_price ||= invoice_direct_internal_lines.sum(&:price).to_money
    end
  end
end
