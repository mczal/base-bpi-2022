# frozen_string_literal: true

module Rates
  module Periods extend ActiveSupport::Concern
    def latest_rate_in month:, year:DateTime.now.localtime.year, group: :bank_of_indonesia
      latest_rate_instance_in(month:month, year:year, group: group)
        .middle
    end
    def latest_rate_instance_in month:, year:DateTime.now.localtime.year, group: :bank_of_indonesia
      current = DateTime.now.change day: 1,month: month,year: year
      Rate.where(group: group).where('created_at < ?', current.end_of_month).first
    end
  end
end
