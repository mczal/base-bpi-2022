# frozen_string_literal: true

module Admin
  module Reports
    class IndexFacade
      def initialize params, current_company
        @params = params
        @current_company = current_company
        @start_date = params[:date]&.to_date&.beginning_of_month || Date.today.beginning_of_month
        @end_date = params[:date]&.to_date&.end_of_month || Date.today
        @table_reports = []
        table_report_generator
      end

      def table_reports
        @table_reports
      end

      def start_date
        @start_date
      end

      def end_date
        @end_date
      end

      def report
        @report ||= Report.find(@params[:id])
      end

      private
        def table_report_generator
          report.report_lines.each do |report_line|
            if report_line.title?
              @table_reports << add_category_report(report_line)
            else
              @table_reports << add_accumulation_report(report_line)
            end
          end
        end

        def add_category_report report_line
          {
            name: report_line.name,
            value: "",
            styles: "font-weight: bold;text-align: left;text-transform: uppercase",
            styles_row: "",
            error_message: ""
          }
        end

        def add_accumulation_report report_line
          error_message = ""
          value = 0

          begin
            value = eval(formula_accumulation_parser(report_line))
          rescue SyntaxError => e
            error_message = "Formula Error: #{report_line.name} --> #{report_line.formula}"
          end

          {
            name: report_line.name,
            value: value,
            styles: "font-weight: bold;background-color: #f8f8f8;text-align: right;text-transform: capitalize;",
            styles_row: "",
            error_message: error_message
          }
        end

        def formula_component_parser report_line
          journal_lines = get_journal_lines(report_line.codes)
          debit_sum_idr = journal_lines.sum(&:debit_idr)
          credit_sum_idr = journal_lines.sum(&:credit_idr)

          formula = report_line.formula
            .gsub(/\$\{debit\}/i, "#{debit_sum_idr.to_i}")
            .gsub(/\$\{credit\}/i, "#{credit_sum_idr.to_i}")

          return formula
        end

        def get_journal_lines codes
          Journal.where(
            company_id: @current_company.id,
            code: codes,
            date: @start_date..@end_date
          )
        end

        def formula_accumulation_parser report_line
          values_formula = {}
          enum_formula = report_line.formula.gsub(/\${.*?}/)
          enum_formula.each do |formula_key|
            values_formula[formula_key] = get_values_formula(formula_key)
          end

          formula = report_line.formula
          values_formula.each do |key, value|
            formula = formula.gsub(key, "#{value.to_f}")
          end

          return formula
        end

        def get_values_formula formula_key
          filtered_formula_key = formula_key.gsub("${", "").gsub("}", "")
          filtered_formula_keys = @table_reports.select do |table_report|
            table_report[:name] == filtered_formula_key
          end.uniq

          return filtered_formula_keys.sum {|table_report| table_report[:value].to_money}
        end
    end
  end
end


