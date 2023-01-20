# frozen_string_literal: true

module Invoices
  module Rates
    extend ActiveSupport::Concern
    include DateHelper

    # _rates: {
    #   rate_id: <rate_id>,
    #   middle: ...
    # }
    def used_rate
      _rates['middle'].to_money
    end

    def rate_instance
      @rate_instance ||= Rate.find_by(id: _rates['rate_id'])
    end

    def rate_info
      @rate_info ||= "KURS BI: #{readable_timestamp rate_instance.created_at.localtime}"
    end

    def convert_to_usd_using_used_rate(value)
      (value / used_rate).round(3).to_money.with_currency(:usd)
    end

    def convert_to_idr_using_used_rate(value)
      return 0 if value.zero?

      (value * _rates['middle']).round(3).to_money.with_currency(:idr)
    end
  end
end
