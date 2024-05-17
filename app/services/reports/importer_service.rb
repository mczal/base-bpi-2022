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
        sheet = xlsx.sheet(index)
        get_report(sheet_name, sheet)

        sheet.each.with_index(1) do |row, i|
          next if i <= 2
          parse_and_save(row, i)
        end
      end
    end

    def get_report name, sheet
      @report = Report.find_or_initialize_by(
        name: report_name(sheet),
        company_id: @company_id,
        group: report_group(sheet),
        display: report_display(sheet),
      )
      @report.assign_attributes({shown: true})
      @report.save! if @report.new_record? || @report.changed?
    end

    def report_group sheet
      sheet.cell(1,2).to_s.strip
    end
    def report_display sheet
      sheet.cell(1,4).to_s.strip.downcase
    end
    def report_name sheet
      sheet.cell(1,5).to_s.strip
    end

    def parse_and_save row, i
      report_line = parse_and_save_report_line(row,i)
      parse_and_save_report_reference(row,i)

      if report_line.present?
        parse_and_save_saved_data(row,i, report_line)
      end
    end

    def parse_and_save_saved_data row, i, report_line
      start = 10
      # 1.times.each.with_index(1) do |_,i|
        srl = SavedReportLine.find_or_initialize_by(
          report_line_id: report_line.id,
          month: 12, year: 2023,
          date: Date.current.change(month:12,year:2023,day:10).end_of_month
        )

        price_idr = row[start].to_s.gsub('.',',')
        if price_idr.strip == '-'
          price_idr = ''
        end
        price_idr = price_idr.present? ? price_idr : 0.to_money
        price_usd = row[start+1].to_s.gsub('.',',')
        if price_usd.strip == '-'
          price_usd = ''
        end
        price_usd = price_usd.present? ? price_usd : 0.to_money.with_currency(:usd)
        srl.assign_attributes(
          price_idr: price_idr,
          price_usd: price_usd,
        )
        srl.save! if srl.new_record? || srl.changed?

        start += 2
      # end
      # TODO NOTICE ONLY: comment to make sure that only 2022 data that needs adjusted, the rest is still in check the data.
      # 2. TODO NOTICE ONLY: after comment. data is still wrong, uncomment again and add to november 2023
      3.times.each.with_index(1) do |_,i|
        srl = SavedReportLine.find_or_initialize_by(
          report_line_id: report_line.id,
          month: i, year: 2024,
          date: Date.current.change(month:i,year:2024,day:10).end_of_month
        )

        price_idr = row[start].to_s.gsub('.',',')
        if price_idr.strip == '-'
          price_idr = ''
        end
        price_idr = price_idr.present? ? price_idr : 0.to_money
        price_usd = row[start+1].to_s.gsub('.',',')
        if price_usd.strip == '-'
          price_usd = ''
        end
        price_usd = price_usd.present? ? price_usd : 0.to_money.with_currency(:usd)
        srl.assign_attributes(
          price_idr: price_idr,
          price_usd: price_usd,
        )
        srl.save! if srl.new_record? || srl.changed?

        start += 2
      end
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
      report_line
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
