module Admin
  module Reports
    module Shows
      class CashFlowXlsxFacade < ::Admin::Reports::Shows::BaseXlsxFacade
        def report
          @report ||= Report.xlsx.cash_flow_xlsx.first
        end
        def source_report_lines
          @source_report_lines ||= Report.html.cash_flow.first.report_lines
        end
        def source_facade
          @source_facade ||= ::Admin::Reports::Shows::CashFlowFacade.new(@params)
        end
      end
    end
  end
end
