# frozen_string_literal: true

module Reports
  class ParserService < Reports::BaseService
    FIELD_MAP = {
      :name => 1,
      :code => 2,
      :formula => 3
    }

    def action
      xlsx.sheets.each_with_index do |report_name, index|
        @sheet = xlsx.sheet(index)
        @report = Report.find_or_initialize_by(
          name: report_name,
          company_id: @company_id,
          shown: true
        )
        @report.save

        @sheet.each.with_index(1) do |row, i|
          next if i < 2 || !is_row_valid?(row)
          parse_and_save(row, i)
        end
      end
    end

    def is_row_valid? row
      return false if row[FIELD_MAP[:name]].blank?
      true
    end

    def parse_and_save row, i
      name = get_name(row)
      code = get_code(row)
      formula = get_formula(row)
      order = i

      group = "category" if name.present? && formula.blank?
      group = "component" if name.present? && code.present? && formula.present?
      group = "accumulation" if name.present? && code.blank? && formula.present?

      new_report_line = @report.report_lines
        .find_or_initialize_by(
          name: name
        )

      if new_report_line.codes.blank?
        new_report_line.codes = [code]
      else
        new_report_line.codes << code
      end

      new_report_line.formula = formula
      new_report_line.group = group
      new_report_line.order = order
      new_report_line.save!
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
  end
end
