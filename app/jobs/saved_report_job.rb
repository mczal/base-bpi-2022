# frozen_string_literal: true

class SavedReportJob < ApplicationJob
  queue_as :default
  attr_reader :date

  def perform date
    month = date.month
    year = date.year

    Report.html.each do |report|
      service = ::SavedReportLines::GenerateFromCurrentDataService.new(report, year, month)
      if !service.run
        Rails.logger.error('[ERROR][SAVED_REPORT_JOB][::SavedReportLines::GenerateFromCurrentDataService#run] FAILED RUN')
        Rails.logger.error("[ERROR][SAVED_REPORT_JOB][::SavedReportLines::GenerateFromCurrentDataService#run] #{service.error_messages}")
      end
    end
  end
end
