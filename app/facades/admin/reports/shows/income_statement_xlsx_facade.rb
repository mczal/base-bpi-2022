module Admin
  module Reports
    module Shows
      class IncomeStatementXlsxFacade < ::Admin::Reports::Shows::BaseXlsxFacade
        def report
          @report ||= Report.xlsx.income_statement_xlsx.first
        end
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
