# frozen_string_literal: true

module Reports
  class BaseService < BaseService
    def initialize file, company_id
      @file = file
      @company_id = company_id
    end

    def validate_before_action
      if !@file.present?
        error_messages << "File tidak ada"
        return
      end
    end

    def is_row_valid? row
      true
    end

    def sheet
      @sheet ||= xlsx.sheet(0)
    end

    def xlsx
      @xlsx ||= Roo::Spreadsheet.open(@file)
    end
  end
end
