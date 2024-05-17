module Admin
  module Reports
    module Shows
      class IncomeStatementXlsxFacade < ::Admin::Reports::Shows::BaseXlsxFacade
        attr_reader :report

        def initialize params, report=nil
          if report.present?
            @report = report
          else
            @report = Report.xlsx.income_statement_xlsx.first
          end
          super(params)
        end

        # def report
          # @report ||= Report.xlsx.income_statement_xlsx.first
        # end
        def source_report_lines
          @source_report_lines ||= Report.html.income_statement.first.report_lines
        end
        def source_facade
          @source_facade ||= ::Admin::Reports::Shows::IncomeStatementFacade.new(@params)
        end
      end
    end
  end
end
