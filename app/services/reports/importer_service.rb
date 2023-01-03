# frozen_string_literal: true

module Reports
  class ImporterService < ::BaseService
    FIELD_MAP = {
      :group => 0,
      :name => 1,
      :code => 2,
      :formula => 3,

      :account_code => 5,
      :account_name => 6,
      :reference_code => 7,
    }
    def initialize file, company_id
      @file = file
      @company_id = company_id
    end

    def action
      xlsx.sheets.each_with_index do |sheet_name, index|
        get_report(sheet_name)
        sheet = xlsx.sheet(index)

        sheet.each.with_index(1) do |row, i|
          next if i < 2
          parse_and_save(row, i)
        end
      end
    end

    def get_report name
      @report = Report.find_or_initialize_by(
        name: name,
        company_id: @company_id
      )
      @report.assign_attributes({shown: true})
      @report.save! if @report.new_record? || @report.changed?
    end

    def parse_and_save row, i
      parse_and_save_report_line(row,i)
      parse_and_save_report_reference(row,i)
    end

    def parse_and_save_report_reference row, i
      return unless is_row_valid_for_report_reference?(row)
      report_reference = get_report_reference(row, i)
      report_reference.save! if report_reference.new_record? || report_reference.changed?
    end
    def parse_and_save_report_line row, i
      return unless is_row_valid_for_report_line?(row)
      report_line = get_report_line(row, i)
      report_line.save! if report_line.new_record? || report_line.changed?
    end

    def get_report_reference row, i
      report_reference = @report.report_references
        .find_or_initialize_by(
          account_code: row[FIELD_MAP[:account_code]].to_s.strip
        )
      report_reference.assign_attributes(
        account_name: row[FIELD_MAP[:account_name]].to_s.strip,
        reference_code: row[FIELD_MAP[:reference_code]].to_s.strip,
      )

      report_reference
    end

    def get_report_line row, i
      if get_group(row) == 'break'
        report_line = @report.report_lines.build(
          name: get_name(row),
          formula: get_formula(row),
          group: get_group(row),
          order: i
        )
        return report_line
      end

      report_line = @report.report_lines
        .find_or_initialize_by(
          name: get_name(row)
        )

      report_line.assign_attributes(
        formula: get_formula(row),
        group: get_group(row),
        order: i
      )

      if report_line.codes.present?
        report_line.codes << get_code(row)
      else
        report_line.codes = [get_code(row)]
      end
      report_line
    end

    def get_group row
      row[FIELD_MAP[:group]].to_s.strip.downcase
    end
    def get_name row
      row[FIELD_MAP[:name]].to_s.strip
    end
    def get_code row
      row[FIELD_MAP[:code]].to_s.strip
    end
    def get_formula(row)
      row[FIELD_MAP[:formula]].to_s.strip
    end

    def is_row_valid_for_report_line? row
      get_group(row).present?
    end
    def is_row_valid_for_report_reference? row
      row[FIELD_MAP[:account_code]].to_s.strip.present?
    end

    def validate_before_action
      if !@file.present?
        error_messages << "File tidak ada"
        return
      end
    end

    def xlsx
      @xlsx ||= Roo::Spreadsheet.open(@file)
    end
  end
end
